public with sharing class QuizSessionHelper {
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
        Integer divisor = 1;
        for (Quiz_Answer__c answer : answers) {
            if (answer.Answer__c == correctAnswer) {
                Integer score = 1000/divisor;
                answer.Score__c = score; 
                Quiz_Player__c player = players.get(answer.Player__c);
                player.Score__c = player.Score__c + score;
                divisor = divisor + 1;
            }
        }
        
        update answers;
        update players.values();
    }
}
