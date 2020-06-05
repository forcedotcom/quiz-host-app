@isTest(isParallel=true)
public class QuizSettingsTest {
    @isTest
    static void constructor_works() {
        Quiz_Settings__mdt record = new Quiz_Settings__mdt(
            Player_App_URL__c = 'someUrl'
        );

        QuizSettings settings = new QuizSettings(record);

        System.assertEquals(record.Player_App_URL__c, settings.playerAppUrl);
    }
}
