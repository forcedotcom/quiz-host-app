public with sharing class QuizSessionTriggerHelper {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name();

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
                QuizSessionService sessionService = new QuizSessionService();
                List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
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
                    QuizSessionHelper sessionHelper = new QuizSessionHelper();
                    sessionHelper.updatePlayerScores();
                } else if (updatedSession.Phase__c == PHASE_REGISTRATION) {
                    // New phase is Registration
                    // Delete all players and answers
                    QuizPlayerService playerService = new QuizPlayerService();
                    playerService.deleteAnswersAndPlayers();
                }
                // Push phase change to player app
                QuizSessionHelper.pushPhaseUpdateToPlayerApp(
                    updatedSession.Phase__c
                );
            }
        }
    }
}
