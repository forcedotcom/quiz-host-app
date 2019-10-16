trigger QuizSessionTrigger on Quiz_Session__c (after update) {
    for (Quiz_Session__c updatedQS : Trigger.new) {
        Quiz_Session__c oldQS = Trigger.oldMap.get(updatedQS.Id);

        // Is phase change?
        if (oldQS.Phase__c != updatedQS.Phase__c) {

            // on Phase__c change to QuestionResult, compute players score
            if (updatedQS.Phase__c == QuizSessionService.Phase.QuestionResults.name()) {
                QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
                quizSessionHelper.updatePlayerScores();
            }
            // on Phase__c change to Registration, delete all players and answers
            else if (updatedQS.Phase__c == QuizSessionService.Phase.Registration.name()) {
                PlayerService playerService = new PlayerService();
                playerService.deleteAnswersAndPlayers();
            }
        }
    }
}