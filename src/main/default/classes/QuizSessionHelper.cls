public with sharing class QuizSessionHelper {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_PRE_QUESTION = QuizSessionService.Phase.PreQuestion.name(),
        PHASE_QUESTION = QuizSessionService.Phase.Question.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name(),
        PHASE_GAME_RESULTS = QuizSessionService.Phase.GameResults.name();

    private static final QuizSettingsService settingsService = new QuizSettingsService();

    // When totalMilliseconds == smallestMilliseconds, score = 1000. With maximum totalMilliseconds, score = 500
    @TestVisible
    private Long computeScore(
        Decimal totalMilliseconds,
        Decimal smallestMilliseconds,
        Decimal differenceBetweenLargestAndSmallestMilliseconds
    ) {
        if (differenceBetweenLargestAndSmallestMilliseconds == 0) {
            return 1000;
        }

        Decimal scoreDifference = totalMilliseconds - smallestMilliseconds;
        Decimal afterFirstDivision =
            scoreDifference / differenceBetweenLargestAndSmallestMilliseconds;
        return (Long) (1000 * (1.00 - (afterFirstDivision / 2.00)));
    }

    public void updatePlayerScores() {
        // Get current question
        QuizSessionService quizSessionService = new QuizSessionService();
        Quiz_Session__c quizSession = quizSessionService.getQuizSession();
        Quiz_Question__c currentQuestion = quizSessionService.getCurrentQuestion(
            quizSession.Id
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
        QuizSessionService quizSessionService = new QuizSessionService();
        Quiz_Session__c quizSession = quizSessionService.getQuizSession();

        if (quizSession.Phase__c == PHASE_REGISTRATION) {
            quizSession.Phase__c = PHASE_PRE_QUESTION;
        } else if (quizSession.Phase__c == PHASE_PRE_QUESTION) {
            quizSession.Phase__c = PHASE_QUESTION;
        } else if (quizSession.Phase__c == PHASE_QUESTION) {
            quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        } else if (quizSession.Phase__c == PHASE_QUESTION_RESULTS) {
            List<Quiz_Question__c> questions = quizSessionService.getSessionQuestions(
                sessionId
            );
            Integer currentQuestionIndex = this.getCurrentQuestionIndex(
                quizSession,
                questions
            );
            if (currentQuestionIndex == questions.size() - 1) {
                quizSession.Phase__c = PHASE_GAME_RESULTS;
            } else {
                quizSession.Phase__c = PHASE_PRE_QUESTION;
                Quiz_Question__c nextQuestion = questions[
                    currentQuestionIndex + 1
                ];
                quizSession.Current_Question__c = nextQuestion.Id;
            }
        } else if (quizSession.Phase__c == PHASE_GAME_RESULTS) {
            quizSession.Phase__c = PHASE_REGISTRATION;
        } else {
            throw new InvalidPhaseException(
                'Unsupported quiz phase: ' + quizSession.Phase__c
            );
        }

        update quizSession;
        return quizSession;
    }

    private Integer getCurrentQuestionIndex(
        Quiz_Session__c quizSession,
        List<Quiz_Question__c> questions
    ) {
        Integer currentQuestionIndex = -1;
        for (
            Integer i = 0;
            currentQuestionIndex == -1 &&
            i < questions.size();
            i++
        ) {
            if (quizSession.Current_Question__c == questions[i].Id) {
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
        request.setBody('{ "Phase__c": "' + phase + '" }');

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
