@isTest(isParallel=true)
public class QuizPlayerStatsRestResourceTest {
    private final static String TEST_BLANK_STATS = '{"wrongCount":0,"totalCount":0,"score":0,"rank":0,"name":"player0","correctCount":0}';
    private final static String TEST_MISSING_PLAYER_ID = '{"message":"Missing id parameter"}';
    private final static String TEST_UNKNOW_PLAYER = '{"message":"No Quiz_Player__c record found"}';

    @isTest
    static void getPlayerStats_works() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/quiz/player/stats';
        request.params.put('id', player.Id);

        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        QuizPlayerStatsRestResource.getPlayerStats();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(TEST_BLANK_STATS, response.responseBody.toString());
    }

    @isTest
    static void getPlayerStats_fails_whenMissingPlayerId() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/quiz/player/stats';

        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        QuizPlayerStatsRestResource.getPlayerStats();
        Test.stopTest();

        System.assertEquals(400, response.statusCode);
        System.assertEquals(
            TEST_MISSING_PLAYER_ID,
            response.responseBody.toString()
        );
    }

    @isTest
    static void getPlayerStats_fails_whenUnknownPlayerId() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/quiz/player/stats';
        request.params.put(
            'id',
            QuizTestUtils.getFakeId(Quiz_Player__c.SObjectType)
        );

        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        QuizPlayerStatsRestResource.getPlayerStats();
        Test.stopTest();

        System.assertEquals(400, response.statusCode);
        System.assertEquals(
            TEST_UNKNOW_PLAYER,
            response.responseBody.toString()
        );
    }
}
