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
    public static Map<String, Integer> getPlayerAnswerStats(ID playerId) {
        if (playerId == null) {
            throw new AuraHandledException('Missing player Id.');
        }
        return answerService.getPlayerAnswerStats(playerId);
    }

    // returns the winner details. Winner name is mapped to value -1
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getWinnerAnswerStats() {
        List<Quiz_Player__c> winnerList = playerService.getPlayersSortedByScore(1);
        if (winnerList.isEmpty()) {
            return new Map<String, Integer>();
        }
        
        Quiz_Player__c winner = winnerList[0];
        Map<String, Integer> winnerMap = answerService.getPlayerAnswerStats(
            winner.Id
        );
        winnerMap.put('Score', Integer.valueOf(winner.Score__c));
        winnerMap.put(winner.Name, -1);
        return winnerMap;
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
