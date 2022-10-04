public with sharing class QuizController {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();

    private static final QuizSessionService sessionService = new QuizSessionService();
    private static final QuizAnswerService answerService = new QuizAnswerService();
    private static final QuizSessionHelper sessionHelper = new QuizSessionHelper();
    private static final QuizPlayerService playerService = new QuizPlayerService();
    private static final QuizSettingsService settingsService = new QuizSettingsService();

    @AuraEnabled(cacheable=true)
    public static QuizAnswerService.PlayerStats getWinnerStats(Id sessionId) {
        requireSessionId(sessionId);
        List<Quiz_Player__c> playerList = playerService.getPlayersSortedByScore(
            sessionId,
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
        requireSessionId(sessionId);
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
    public static Map<String, Integer> getAnswerStats(Id sessionId) {
        requireSessionId(sessionId);
        return answerService.getAnswerStats(sessionId);
    }

    @AuraEnabled
    public static List<QuizPlayer> getPlayersSortedByScore(
        Id sessionId,
        Integer maxFetchCount
    ) {
        requireSessionId(sessionId);
        List<Quiz_Player__c> players = playerService.getPlayersSortedByScore(
            sessionId,
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
        requireSessionId(sessionId);
        Quiz_Session__c session = sessionHelper.triggerNextPhase(sessionId);
        return new QuizSession(session);
    }

    @AuraEnabled
    public static void resetGame(Id sessionId) {
        requireSessionId(sessionId);
        // Reset session (current question, phase)
        Quiz_Session__c session = sessionService.getQuizSession(sessionId);
        List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
            session.Id
        );
        if (questions.size() > 0) {
            session.Current_Question__c = questions[0].Id;
        }
        session.Phase__c = PHASE_REGISTRATION;
        update session;
        // Delete all players and answers
        playerService.deletePlayers(session.Id);
        // Push phase change to player app
        QuizSessionHelper.pushPhaseUpdateToPlayerApp(
            sessionId,
            session.Phase__c
        );
    }

    @AuraEnabled
    public static QuizSettings getAndCheckSettings() {
        try {
            Quiz_Settings__mdt settings = settingsService.getAndCheckSettings();
            return new QuizSettings(settings);
        } catch (Exception e) {
            throw new AuraHandledException(
                'Failed to validate Quiz app settings: ' + e.getMessage()
            );
        }
    }

    private static void requireSessionId(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
    }
}
