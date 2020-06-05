public with sharing class QuizSessionHelper {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_PRE_QUESTION = QuizSessionService.Phase.PreQuestion.name(),
        PHASE_QUESTION = QuizSessionService.Phase.Question.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name(),
        PHASE_GAME_RESULTS = QuizSessionService.Phase.GameResults.name();

    private static final QuizSettingsService settingsService = new QuizSettingsService();

    // When curAnswerTimestamp == minAnswerTimestamp, score = 1000
    // With curAnswerTimestamp == maxAnswerTimestamp, score = 500
    @TestVisible
    private Long computeScore(
        Decimal curAnswerTimestamp,
        Decimal minAnswerTimestamp,
        Decimal minMaxTimestampDelta
    ) {
        // If one or zero answer, award full points (avoids zero division)
        if (minMaxTimestampDelta == 0) {
            return 1000;
        }

        Decimal delayFromFastestAnswer =
            curAnswerTimestamp - minAnswerTimestamp;
        // Calulate speed factor: 0 = fastest, 1 = slowest
        Decimal speedFactor = delayFromFastestAnswer / minMaxTimestampDelta;
        return (Long) (1000 * (1.00 - (speedFactor / 2.00)));
    }

    public void updatePlayerScores() {
        // Get current question
        QuizSessionService sessionService = new QuizSessionService();
        Quiz_Session__c session = sessionService.getQuizSession();
        Quiz_Question__c currentQuestion = sessionService.getCurrentQuestion(
            session.Id
        );

        // Get correct answers
        QuizAnswerService answerService = new QuizAnswerService();
        List<Quiz_Answer__c> answers = answerService.getCorrectAnswers(
            currentQuestion
        );
        if (answers.isEmpty()) {
            return;
        }

        // Get players
        QuizPlayerService playerService = new QuizPlayerService();
        Map<Id, Quiz_Player__c> allPlayers = playerService.getPlayers();
        List<Quiz_Player__c> updatedPlayers = new List<Quiz_Player__c>();

        // Get answer min and max timestamps
        Decimal minTimestamp = answers[0].Timestamp__c;
        Decimal maxTimestamp = answers[answers.size() - 1].Timestamp__c;
        Decimal timestampDelta = maxTimestamp - minTimestamp;

        // Compute and assign scores
        for (Quiz_Answer__c answer : answers) {
            // Score correct answer
            Long score = computeScore(
                answer.Timestamp__c,
                minTimestamp,
                timestampDelta
            );
            answer.IsCorrect__c = true;
            answer.Score__c = score;
            // Update player score
            Quiz_Player__c player = allPlayers.get(answer.Player__c);
            player.Score__c += score;
            updatedPlayers.add(player);
        }

        update answers;
        update updatedPlayers;

        // Refresh ranks
        playerService.assignRanking();
    }

    public Quiz_Session__c triggerNextPhase(Id sessionId) {
        QuizSessionService sessionService = new QuizSessionService();
        Quiz_Session__c session = sessionService.getQuizSession();

        if (session.Phase__c == PHASE_REGISTRATION) {
            session.Phase__c = PHASE_PRE_QUESTION;
        } else if (session.Phase__c == PHASE_PRE_QUESTION) {
            session.Phase__c = PHASE_QUESTION;
        } else if (session.Phase__c == PHASE_QUESTION) {
            session.Phase__c = PHASE_QUESTION_RESULTS;
        } else if (session.Phase__c == PHASE_QUESTION_RESULTS) {
            List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
                sessionId
            );
            Integer currentQuestionIndex = this.getCurrentQuestionIndex(
                session,
                questions
            );
            if (currentQuestionIndex == questions.size() - 1) {
                session.Phase__c = PHASE_GAME_RESULTS;
            } else {
                session.Phase__c = PHASE_PRE_QUESTION;
                Quiz_Question__c nextQuestion = questions[
                    currentQuestionIndex + 1
                ];
                session.Current_Question__c = nextQuestion.Id;
            }
        } else if (session.Phase__c == PHASE_GAME_RESULTS) {
            session.Phase__c = PHASE_REGISTRATION;
        } else {
            throw new InvalidPhaseException(
                'Unsupported quiz phase: ' + session.Phase__c
            );
        }

        update session;
        return session;
    }

    private Integer getCurrentQuestionIndex(
        Quiz_Session__c session,
        List<Quiz_Question__c> questions
    ) {
        Integer currentQuestionIndex = -1;
        for (
            Integer i = 0;
            currentQuestionIndex == -1 &&
            i < questions.size();
            i++
        ) {
            if (session.Current_Question__c == questions[i].Id) {
                currentQuestionIndex = i;
            }
        }
        return currentQuestionIndex;
    }

    @future(callout=true)
    public static void pushPhaseUpdateToPlayerApp(String phase) {
        Quiz_Settings__mdt settings = settingsService.get();

        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(settings.Player_App_URL__c + '/api/quiz-sessions');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Api-Key', settings.Quiz_Api_Key__c);
        request.setBody('{ "phase": "' + phase + '" }');

        Http httpClient = new Http();
        HttpResponse response = httpClient.send(request);
        if (response.getStatusCode() != 200) {
            throw new QuizPhasePushException(
                'Failed to push quiz phase update: HTTP' +
                response.getStatusCode() +
                ' ' +
                response.getBody()
            );
        }
    }

    public class QuizPhasePushException extends Exception {
    }

    public class InvalidPhaseException extends Exception {
    }
}
