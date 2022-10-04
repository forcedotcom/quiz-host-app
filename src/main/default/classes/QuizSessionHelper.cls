public with sharing class QuizSessionHelper {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_PRE_QUESTION = QuizSessionService.Phase.PreQuestion.name(),
        PHASE_QUESTION = QuizSessionService.Phase.Question.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name(),
        PHASE_GAME_RESULTS = QuizSessionService.Phase.GameResults.name();

    private static final QuizSettingsService settingsService = new QuizSettingsService();
    private static final QuizSessionService sessionService = new QuizSessionService();

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

    public void updatePlayerScores(Id sessionId) {
        // Get current question
        Quiz_Session__c session = sessionService.getQuizSession(sessionId);
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
        }
        update answers;

        // Refresh ranks
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanks(session.Id);
    }

    public Quiz_Session__c triggerNextPhase(Id sessionId) {
        Quiz_Session__c session = sessionService.getQuizSession(sessionId);

        if (session.Phase__c == PHASE_REGISTRATION) {
            session.Phase__c = PHASE_PRE_QUESTION;
        } else if (session.Phase__c == PHASE_PRE_QUESTION) {
            session.Phase__c = PHASE_QUESTION;
        } else if (session.Phase__c == PHASE_QUESTION) {
            session.Phase__c = PHASE_QUESTION_RESULTS;
            updatePlayerScores(session.Id);
        } else if (session.Phase__c == PHASE_QUESTION_RESULTS) {
            List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
                sessionId
            );
            Integer currentQuestionIndex = this.getCurrentQuestionIndex(
                session,
                questions
            );
            // Last question, show game results
            if (currentQuestionIndex == questions.size() - 1) {
                session.Phase__c = PHASE_GAME_RESULTS;
            } else {
                // Move to next question
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
        // Push phase change to player app
        QuizSessionHelper.pushPhaseUpdateToPlayerApp(
            session.Id,
            session.Phase__c
        );
        return session;
    }

    public Quiz_Session__c resetSession(Id sessionId) {
        // Reset session
        Quiz_Session__c session = sessionService.getQuizSession(sessionId);
        session.Phase__c = PHASE_REGISTRATION;
        // Reset current question
        List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
            session.Id
        );
        if (questions.size() > 0) {
            session.Current_Question__c = questions[0].Id;
        }
        update session;
        // Delete all players and answers
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.deletePlayers(session.Id);
        // Push phase change to player app
        QuizSessionHelper.pushPhaseUpdateToPlayerApp(
            session.Id,
            session.Phase__c
        );
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
    public static void pushPhaseUpdateToPlayerApp(Id sessionId, String phase) {
        Quiz_Settings__mdt settings = settingsService.get();

        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(
            settings.Player_App_URL__c +
            '/api/quiz-sessions/' +
            sessionId
        );
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
