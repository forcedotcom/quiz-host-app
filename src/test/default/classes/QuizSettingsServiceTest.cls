@isTest(isParallel=true)
public class QuizSettingsServiceTest {
    @isTest
    static void checkSettings_works() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );
        QuizSettingsService settingsService = new QuizSettingsService();

        settingsService.checkSettings();
    }

    @isTest
    static void checkSettings_failsWhenPlayerAppIsUnreachable() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSimpleHttpResponse(404)
        );
        QuizSettingsService settingsService = new QuizSettingsService();

        try {
            settingsService.checkSettings();
            // expect to fail
            System.assert(false);
        } catch (QuizSettingsService.PlayerAppUrlException e) {
            System.assert(true);
        }
    }
}
