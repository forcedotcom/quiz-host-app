public with sharing class QuizController {
    private static QuizSessionService quizSessionService = new QuizSessionService();
    private static PlayerService playerService = new PlayerService();

    @AuraEnabled(cacheable=true)
    public static String getMobileAppUrl() {
        Quiz_Settings__mdt quizMetadata = [
            SELECT Mobile_App_Url__c
            FROM Quiz_Settings__mdt
        ];
        if (quizMetadata == null) {
            throw new AuraHandledException('Missing mobile app url.');
        }

        return quizMetadata.Mobile_App_Url__c;
    }

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

    // Using timestamp parameter as a cache buster
    @AuraEnabled
    public static Quiz_Session__c getQuizSession(Long timestamp) {
        return quizSessionService.getQuizSession();
    }
}
