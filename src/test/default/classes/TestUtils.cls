@isTest
public class TestUtils {
    private static Integer idCounter = 1;

    public static String getFakeId(Schema.SObjectType objectType) {
        String result = String.valueOf(idCounter++);
        return objectType.getDescribe().getKeyPrefix() +
            '0'.repeat(12 - result.length()) +
            result;
    }

    public class MockSuccessHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }
}
