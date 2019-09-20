trigger QuizSessionTrigger on Quiz_Session__c (after update) {
    Boolean deletePlayer = false;
    Boolean updateAnswerToCurrentQuestion = false;
    for (Quiz_Session__c updatedQS : Trigger.new) {
        Quiz_Session__c oldQS = Trigger.oldMap.get(updatedQS.Id);
        // on Phase__c change to PostQuestion, compute score and update the score field on Quiz_Answer__c and Quiz_Player__c
        if (oldQS.Phase__c != updatedQS.Phase__c && updatedQS.Phase__c == QuizSessionService.Phase.PostQuestion.name()) {
            updateAnswerToCurrentQuestion = true;
        }
        // on Phase__c change to Registration, delete all players and answers
        if (oldQS.Phase__c != updatedQS.Phase__c && updatedQS.Phase__c == QuizSessionService.Phase.Registration.name()) {
            deletePlayer = true;
        }
    }

    if (updateAnswerToCurrentQuestion) {
        QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
        quizSessionHelper.updateScore();
    }

    if (deletePlayer) {
        PlayerService playerService = new PlayerService();
        playerService.deleteAnswersAndPlayers();
    }
}