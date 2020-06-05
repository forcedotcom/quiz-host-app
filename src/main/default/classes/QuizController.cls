public with sharing class QuizController {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();

    private static final QuizSessionService sessionService = new QuizSessionService();
    private static final QuizAnswerService answerService = new QuizAnswerService();
    private static final QuizSessionHelper sessionHelper = new QuizSessionHelper();
    private static final QuizPlayerService playerService = new QuizPlayerService();
    private static final QuizSettingsService settingsService = new QuizSettingsService();

    @AuraEnabled(cacheable=true)
    public static QuizSettings getQuizSettings() {
        Quiz_Settings__mdt settings = settingsService.get();
        return new QuizSettings(settings);
    }

    @AuraEnabled(cacheable=true)
    public static QuizAnswerService.PlayerStats getWinnerStats() {
        List<Quiz_Player__c> playerList = playerService.getPlayersSortedByScore(
            1
        );
        if (playerList.isEmpty()) {
            throw new AuraHandledException('No player found');
        }
        return answerService.getPlayerAnswerStats(playerList[0].Id);
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
        } catch (QuizAbstractDataService.NoRecordFoundException e) {
            throw new AuraHandledException(
                'Failed to get player stats: ' + e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static QuizQuestion getCurrentQuestion(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        Quiz_Question__c question = sessionService.getCurrentQuestion(
            sessionId
        );
        if (question == null) {
            throw new AuraHandledException(
                'Missing current question for session.'
            );
        }
        return new QuizQuestion(question);
    }

    @AuraEnabled
    public static Map<String, Integer> getAnswerStats() {
        return answerService.getAnswerStats();
    }

    @AuraEnabled
    public static List<QuizPlayer> getPlayersSortedByScore(
        Integer maxFetchCount
    ) {
        List<Quiz_Player__c> players = playerService.getPlayersSortedByScore(
            maxFetchCount
        );
        return QuizPlayer.fromRecordList(players);
    }

    @AuraEnabled
    public static QuizSession getQuizSession() {
        Quiz_Session__c session = sessionService.getQuizSession();
        return new QuizSession(session);
    }

    @AuraEnabled
    public static QuizSession triggerNextPhase(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        Quiz_Session__c session = sessionHelper.triggerNextPhase(sessionId);
        return new QuizSession(session);
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

    @AuraEnabled
    public static void checkSettings() {
        try {
            settingsService.checkSettings();
        } catch (Exception e) {
            throw new AuraHandledException(
                'Failed to validate Quiz app settings: ' + e.getMessage()
            );
        }
    }
}
