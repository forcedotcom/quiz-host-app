public with sharing class QuizController {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();

    private static final QuizSessionService sessionService = new QuizSessionService();
    private static final QuizAnswerService answerService = new QuizAnswerService();
    private static final QuizSessionHelper sessionHelper = new QuizSessionHelper();
    private static final QuizPlayerService playerService = new QuizPlayerService();
    private static final QuizSettingsService settingsService = new QuizSettingsService();

    @AuraEnabled(cacheable=true)
    public static Quiz_Settings__mdt getQuizSettings() {
        return settingsService.get();
    }

    @AuraEnabled(cacheable=true)
    public static QuizAnswerService.PlayerStats getWinnerStats() {
        List<Quiz_Player__c> playerList = playerService.getPlayersSortedByScore(
            1
        );
        if (playerList.isEmpty()) {
            throw new AuraHandledException('No player found');
        }
        try {
            return answerService.getPlayerAnswerStats(playerList[0].Id);
        } catch (QuizAnswerService.UnknownUserException e) {
            throw new AuraHandledException('Unknown player');
        }
    }

    @AuraEnabled(cacheable=true)
    public static QuizAnswerService.PlayerStats getPlayerAnswerStats(
        Id playerId
    ) {
        if (playerId == null) {
            throw new AuraHandledException('Missing player Id.');
        }
        try {
            return answerService.getPlayerAnswerStats(playerId);
        } catch (QuizAnswerService.UnknownUserException e) {
            throw new AuraHandledException('Unknown player');
        }
    }

    @AuraEnabled
    public static Quiz_Question__c getCurrentQuestion(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return sessionService.getCurrentQuestion(sessionId);
    }

    @AuraEnabled
    public static Map<String, Integer> getAnswerStats() {
        return answerService.getAnswerStats();
    }

    @AuraEnabled
    public static List<Quiz_Player__c> getPlayersSortedByScore(
        Integer maxFetchCount
    ) {
        return playerService.getPlayersSortedByScore(maxFetchCount);
    }

    @AuraEnabled
    public static Quiz_Session__c getQuizSession() {
        return sessionService.getQuizSession();
    }

    @AuraEnabled
    public static Quiz_Session__c triggerNextPhase(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return sessionHelper.triggerNextPhase(sessionId);
    }

    @AuraEnabled
    public static void resetGame() {
        // Reset session (current question, phase)
        Quiz_Session__c session = sessionService.getQuizSession();
        List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
            session.Id
        );
        if (questions.size() > 0) {
            session.Current_Question__c = questions[0].Id;
        }
        session.Phase__c = PHASE_REGISTRATION;
        update session;
        // Delete all players and answers
        playerService.deleteAnswersAndPlayers();
        // Push phase change to player app
        QuizSessionHelper.pushPhaseUpdateToPlayerApp(session.Phase__c);
    }
}
