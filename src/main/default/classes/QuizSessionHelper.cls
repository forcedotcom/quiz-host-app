public with sharing class QuizSessionHelper {
    public Long computeScore(Decimal totalMilliseconds, 
        Decimal smallestMilliseconds, Decimal differenceBetweenLargestAndSmallestMilliseconds) {
        // When totalMilliseconds == smallestMilliseconds, score = 1000. With maximum totalMilliseconds, score = 500
        if (differenceBetweenLargestAndSmallestMilliseconds == 0) {
            return 1000;
        }
        
        Decimal scoreDifference = totalMilliseconds - smallestMilliseconds;
        Decimal afterFirstDivision = (1.00 * scoreDifference)/differenceBetweenLargestAndSmallestMilliseconds;
        return (Long)(1000 * ( 1.00 - (afterFirstDivision / 2.00 )));
    }

    public void updateScore() {
        QuizSessionService quizSessionService = new QuizSessionService();
        Quiz_Session__c quizSession = quizSessionService.getQuizSession();        
        Quiz_Question__c currentQuestion = quizSessionService.getCurrentQuestion(quizSession.Id);
        String correctAnswer = currentQuestion.Correct_Answer__c;
        
        PlayerService playerService = new PlayerService();        
        Map<ID, Quiz_Player__c> players = playerService.getPlayers();
        Set<Id> playerIds = players.keySet();
        
        AnswerService answerService = new AnswerService();                
        List<Quiz_Answer__c> answers = answerService.getAnswersOfPlayerIdsAndQuestionId(playerIds, currentQuestion.Id);
        if (answers.isEmpty()) {
            return;
        }
        
        // find smallest and largest milliseconds
        Decimal smallestMilliseconds = answers[0].Milliseconds__c;
        Decimal largestMiliseconds = answers[0].Milliseconds__c;
        for (Quiz_Answer__c answer : answers) {
            if (answer.Milliseconds__c > largestMiliseconds) {
                largestMiliseconds = answer.Milliseconds__c;
            }
           if (answer.Milliseconds__c < smallestMilliseconds) {
                smallestMilliseconds = answer.Milliseconds__c;
            } 
        }        

        // compute and assign scores
        Decimal differenceBetweenLargestAndSmallestMilliseconds = largestMiliseconds - smallestMilliseconds;
        for (Quiz_Answer__c answer : answers) {
            if (answer.Answer__c == correctAnswer) {
                Long score = computeScore(
                    answer.Milliseconds__c, 
                    smallestMilliseconds, differenceBetweenLargestAndSmallestMilliseconds);
                answer.Score__c = score; 
                Quiz_Player__c player = players.get(answer.Player__c);
                player.Score__c = player.Score__c + score;
            }
        }
        
        update answers;
        update players.values();
    }
}
