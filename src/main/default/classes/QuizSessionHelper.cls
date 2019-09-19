public with sharing class QuizSessionHelper {
    public void updateScore() {
        QuizSessionService quizSessionService = new QuizSessionService();
        Quiz_Session__c quizSession = quizSessionService.getQuizSession();        
        Quiz_Question__c currentQuestion = quizSessionService.getCurrentQuestion(quizSession.Id);
        String correctAnswer = currentQuestion.Correct_Answer__c;
        
        PlayerService playerService = new PlayerService();        
        List<Quiz_Player__c> players = playerService.getPlayers();
        List<Quiz_Answer__c> currentQuestionAnswers = new List<Quiz_Answer__c>();
        
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
}
