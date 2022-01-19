@isTest(isParallel=true)
public class QuizControllerTest {
    private static String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();
    private static String PHASE_QUESTION = QuizSessionService.Phase.Question.name();

    @isTest
    static void getWinnerStats_works() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        QuizAnswerService.PlayerStats stats = QuizController.getWinnerStats();
        Test.stopTest();
    }

    @isTest
    static void getWinnerStats_failsWhenNoPlayers() {
        try {
            QuizController.getWinnerStats();
            // expect to fail
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void getPlayerAnswerStats_works() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        QuizController.getPlayerAnswerStats(player.Id);
        Test.stopTest();
    }

    @isTest
    static void getPlayerAnswerStats_failsWhenMissingPlayerId() {
        try {
            QuizController.getPlayerAnswerStats(null);
            // expect to fail
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void getPlayerAnswerStats_failsWhenUnknownPlayerId() {
        Id fakePlayerId = QuizTestUtils.getFakeId(Quiz_Player__c.SObjectType);
        try {
            QuizController.getPlayerAnswerStats(fakePlayerId);
            // expect to fail
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void resetGame_works() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        Quiz_Question__c question1 = session.Current_Question__r;
        Quiz_Question__c question2 = QuizSessionTestFactory.createQuizQuestion();
        Quiz_Answer__c quizAnswer1 = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question1.Id,
            question1.Correct_Answer__c
        );
        session.Phase__c = PHASE_QUESTION;
        session.Current_Question__r = question2;
        update session;

        Test.startTest();
        QuizController.resetGame();
        Test.stopTest();

        Integer playerCount = Database.countQuery(
            'SELECT COUNT() FROM Quiz_Player__c WITH SECURITY_ENFORCED'
        );
        System.assertEquals(0, playerCount);
        Integer answerCount = Database.countQuery(
            'SELECT COUNT() FROM Quiz_Answer__c WITH SECURITY_ENFORCED'
        );
        System.assertEquals(0, answerCount);
        QuizSessionService sessionService = new QuizSessionService();
        Quiz_Session__c updatedSession = sessionService.getQuizSession();
        System.assertEquals(PHASE_REGISTRATION, updatedSession.Phase__c);
        System.assertEquals(question1.Id, updatedSession.Current_Question__c);
    }
}
