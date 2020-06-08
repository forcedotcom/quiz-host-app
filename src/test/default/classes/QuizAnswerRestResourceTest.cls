@isTest(isParallel=true)
public class QuizAnswerRestResourceTest {
    private final static String TEST_ANSWER = 'B';
    private static final String PHASE_QUESTION = QuizSessionService.Phase.Question.name();

    @isTest
    static void submitAnswer_works() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        RestResponse response = new RestResponse();
        RestContext.response = response;

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        session.Phase__c = PHASE_QUESTION;
        update session;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        QuizAnswerRestResource.submitAnswer(player.Id, TEST_ANSWER);
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
    }

    @isTest
    static void submitAnswer_failsWhenPhaseIsInvalid() {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        QuizAnswerRestResource.submitAnswer(player.Id, TEST_ANSWER);
        Test.stopTest();

        System.assertEquals(400, response.statusCode);
        System.assert(response.responseBody.toString().contains('too late'));
    }

    @isTest
    static void submitAnswer_failsWhenDuplicateAnswer() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        RestResponse response = new RestResponse();
        RestContext.response = response;

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        session.Phase__c = PHASE_QUESTION;
        update session;
        Quiz_Question__c question = session.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            question.Correct_Answer__c
        );

        Test.startTest();
        QuizAnswerRestResource.submitAnswer(player.Id, TEST_ANSWER);
        Test.stopTest();

        System.assertEquals(400, response.statusCode);
        System.assert(response.responseBody.toString().contains('duplicate'));
    }

    @isTest
    static void submitAnswer_failsWhenOtherError() {
        RestResponse response = new RestResponse();
        RestContext.response = response;

        Test.startTest();
        QuizAnswerRestResource.submitAnswer(null, TEST_ANSWER);
        Test.stopTest();

        System.assertEquals(500, response.statusCode);
    }
}
