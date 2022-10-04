@isTest(isParallel=true)
public class QuizSettingsServiceTest {
    @isTest
    static void getAndCheckSettings_works() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );
        QuizSettingsService settingsService = new QuizSettingsService();

        settingsService.getAndCheckSettings();
    }

    @isTest
    static void getAndCheckSettings_failsWhenPlayerAppIsUnreachable() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSimpleHttpResponse(404)
        );
        QuizSettingsService settingsService = new QuizSettingsService();

        try {
            settingsService.getAndCheckSettings();
            // expect to fail
            System.assert(false);
        } catch (QuizSettingsService.PlayerAppUrlException e) {
            System.assert(true);
        }
    }
}
