public with sharing class QuizController {
    private static QuizSessionService quizSessionService = new QuizSessionService();
    private static PlayerService playerService = new PlayerService();
    
    @AuraEnabled(cacheable=true)
    public static List<Quiz_Question__c> getQuestionList(String sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        
        return quizSessionService.getSessionQuestions(sessionId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Quiz_Player__c> getPlayerList(Integer maxFetchCount) {
        return playerService.getPlayersSortedByScore(maxFetchCount);
    }

    @AuraEnabled(cacheable=true)
    public static Quiz_Session__c getQuizSession() {
        return quizSessionService.getQuizSession();
    }     
}
