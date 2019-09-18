trigger QuizSessionTrigger on Quiz_Session__c (after update) {
    Boolean deletePlayer = false;
    Boolean updateAnswerToCurrentQuestion = false;

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
        QuizSessionService quizSessionService = new QuizSessionService();
        Quiz_Session__c quizSession = quizSessionService.getQuizSession();
        String currentQuestionID = quizSession.Current_Question__c;
        
        Quiz_Question__c currentQuestion = [SELECT Id, Name, Correct_Answer__c FROM Quiz_Question__c WHERE Id =: currentQuestionID];
        String correctAnswer = currentQuestion.Correct_Answer__c;
        
        List<Quiz_Player__c> players = [SELECT ID FROM Quiz_Player__c];
        List<Quiz_Answer__c> currentQuestionAnswers = new List<Quiz_Answer__c>();
        
        // get answers linked to current question
        AnswerService answerService = new AnswerService();
        for (Quiz_Player__c player : players) {
            Quiz_Answer__c answer = answerService.getFromPlayer(player.ID, currentQuestionID);
            // compute score
            if (answer.Answer__c == correctAnswer) {
                // TODO: make it 1000/sorted order
                Integer score = 1000;
                answer.Score__c = score; 
                player.Score__c = player.Score__c + score;
                System.debug('about to update player score: ' + player.Score__c);
            }
            currentQuestionAnswers.add(answer);
        }
        
        update currentQuestionAnswers;
        // update on player score is not working
        update players;
    }

    if (deletePlayer) {
        // need delete answers before delete players
        List<Quiz_Answer__c> answers = [SELECT ID FROM Quiz_Answer__c];
        delete answers;

        List<Quiz_Player__c> players = [SELECT ID FROM Quiz_Player__c];
        delete players;
    }
}