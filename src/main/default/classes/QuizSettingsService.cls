public class QuizSettingsService extends QuizAbstractDataService {
    public Quiz_Settings__mdt get() {
        Quiz_Settings__mdt settings = (Quiz_Settings__mdt) getSingleRecord(
            [
                SELECT
                    Id,
                    Player_App_URL__c,
                    Player_App_URL_Minified__c,
                    Quiz_API_Key__c
                FROM Quiz_Settings__mdt
            ]
        );
        // Normalize player app URL
        settings.Player_App_URL__c = settings.Player_App_URL__c.removeEnd('/');
        return settings;
    }
}
