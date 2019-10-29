public with sharing class QuizController {
    private static final QuizSessionService quizSessionService = new QuizSessionService();
    private static final AnswerService answerService = new AnswerService();
    private static final QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
    private static final PlayerService playerService = new PlayerService();
    private static final QuizSettingsService settingsService = new QuizSettingsService();

    @AuraEnabled(cacheable=true)
    public static Quiz_Settings__mdt getQuizSettings() {
        return settingsService.get();
    }

    @AuraEnabled
    public static Quiz_Question__c getCurrentQuestion(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return quizSessionService.getCurrentQuestion(sessionId);
    }

    @AuraEnabled
    public static Map<String, Integer> getAnswerMap() {
        return answerService.getAnswerMap();
    }

    @AuraEnabled
    public static List<Quiz_Player__c> getPlayersSortedByScore(
        Integer maxFetchCount
    ) {
        return playerService.getPlayersSortedByScore(maxFetchCount);
    }

    @AuraEnabled
    public static Quiz_Session__c getQuizSession() {
        return quizSessionService.getQuizSession();
    }

    @AuraEnabled
    public static Quiz_Session__c triggerNextPhase(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return quizSessionHelper.triggerNextPhase(sessionId);
    }
}
