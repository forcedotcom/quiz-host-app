public with sharing class QuizSessionTriggerHelper {
    private static String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
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
                    PlayerService playerService = new PlayerService();
                    playerService.deleteAnswersAndPlayers();
                }
            }
        }
    }
}
