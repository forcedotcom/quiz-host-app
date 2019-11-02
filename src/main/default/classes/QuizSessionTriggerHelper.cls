public with sharing class QuizSessionTriggerHelper {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name();

    private static final QuizSettingsService settingsService = new QuizSettingsService();

    public static void beforeUpdate(
        List<Quiz_Session__c> updatedSessions,
        Map<Id, Quiz_Session__c> oldSessions
    ) {
        for (Quiz_Session__c updatedSession : updatedSessions) {
            Quiz_Session__c oldSession = oldSessions.get(updatedSession.Id);
            // Is phase change to Registration
            if (
                oldSession.Phase__c != updatedSession.Phase__c &&
                updatedSession.Phase__c == PHASE_REGISTRATION
            ) {
                // Reset current question
                QuizSessionService quizSessionService = new QuizSessionService();
                List<Quiz_Question__c> questions = quizSessionService.getSessionQuestions(
                    updatedSession.Id
                );
                if (questions.size() > 0) {
                    updatedSession.Current_Question__c = questions[0].Id;
                }
            }
        }
    }

    public static void afterUpdate(
        List<Quiz_Session__c> updatedSessions,
        Map<Id, Quiz_Session__c> oldSessions
    ) {
        for (Quiz_Session__c updatedSession : updatedSessions) {
            Quiz_Session__c oldSession = oldSessions.get(updatedSession.Id);
            // Is phase change?
            if (oldSession.Phase__c != updatedSession.Phase__c) {
                // New phase is QuestionResult
                if (updatedSession.Phase__c == PHASE_QUESTION_RESULTS) {
                    // Compute players score
                    QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
                    quizSessionHelper.updatePlayerScores();
                } else if (updatedSession.Phase__c == PHASE_REGISTRATION) {
                    // New phase is Registration
                    // Delete all players and answers
                    QuizPlayerService playerService = new QuizPlayerService();
                    playerService.deleteAnswersAndPlayers();
                }
                // Push phase change to player app
                pushPhaseUpdateToPlayerApp(updatedSession.Phase__c);
            }
        }
    }

    @future(callout=true)
    private static void pushPhaseUpdateToPlayerApp(String phase) {
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
}
