trigger QuizSessionTrigger on Quiz_Session__c (after update) {
    Boolean deletePlayer = false;
    Boolean updateAnswerToCurrentQuestion = false;
    private static PlayerService playerService = new PlayerService();
    private static QuizSessionService quizSessionService = new QuizSessionService();

    for (Quiz_Session__c updatedQS : Trigger.new) {
        Quiz_Session__c oldQS = Trigger.oldMap.get(updatedQS.Id);
        // on Phase__c change to PostQuestion, compute score and update the score field on Quiz_Answer__c and Quiz_Player__c
        if (oldQS.Phase__c != updatedQS.Phase__c && updatedQS.Phase__c == 'PostQuestion') {
            updateAnswerToCurrentQuestion = true;
        }
        // on Phase__c change to Registration, delete all players and answers
        if (oldQS.Phase__c != updatedQS.Phase__c && updatedQS.Phase__c == 'Registration') {
            deletePlayer = true;
        }
    }

    if (updateAnswerToCurrentQuestion) {
        // get all players, since all players are in the current game
        Quiz_Session__c quizSession = quizSessionService.getQuizSession();        
        Quiz_Question__c currentQuestion = quizSessionService.getCurrentQuestion(quizSession.Id);
        String correctAnswer = currentQuestion.Correct_Answer__c;
        
        List<Quiz_Player__c> players = playerService.getPlayers();
        List<Quiz_Answer__c> currentQuestionAnswers = new List<Quiz_Answer__c>();
        
        // get answers linked to current question
        AnswerService answerService = new AnswerService();
        for (Quiz_Player__c player : players) {
            Quiz_Answer__c answer = answerService.getFromPlayer(player.ID, currentQuestion.Id);
            // compute score
            if (answer.Answer__c == correctAnswer) {
                // TODO: make it 1000/sorted order
                Integer score = 1000;
                answer.Score__c = score; 
                player.Score__c = player.Score__c + score;
            }
            currentQuestionAnswers.add(answer);
        }
        
        update currentQuestionAnswers;
        update players;
    }

    if (deletePlayer) {
        playerService.deleteAnswersAndPlayers();
    }
}