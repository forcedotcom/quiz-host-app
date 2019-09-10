public class PlayerController {

    private static QuizSessionService quizSessionService = new QuizSessionService();
    private static PlayerService playerService = new PlayerService();


    @AuraEnabled
    public static Boolean isNicknameAvailable(String nickname) {
        try {
            playerService.getFromName(nickname);
            return false;
        } catch (AbstractDataService.NoRecordFoundException e) {
            return true;
        }
    }

    @AuraEnabled
    public static Id register(String nickname) {
        try {
            Quiz_Player__c player = playerService.create(nickname);
            return player.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to register player.');
        }
    }

    @AuraEnabled
    public static void answer(Id playerId, String answer) {
        try {
            Quiz_Session__c session = quizSessionService.getQuizSession();
            insert new Quiz_Answer__c(Player__c = playerId, Question__c = session.Current_Question__c, Answer__c = answer);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to save answer.');
        }
    }

    @AuraEnabled
    public static Quiz_Session__c getQuizSession() {
        try {
            return quizSessionService.getQuizSession();
        } catch (AbstractDataService.NoRecordFoundException e) {
            throw new AuraHandledException('Could not find current quiz session.');
        }
    }
}
