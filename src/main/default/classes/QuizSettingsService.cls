public class QuizSettingsService extends QuizAbstractDataService {
    public Quiz_Settings__mdt get() {
        return (Quiz_Settings__mdt) getSingleRecord(
            [
                SELECT
                    Id,
                    Player_App_URL__c,
                    Player_App_URL_Minified__c,
                    Quiz_API_Key__c
                FROM Quiz_Settings__mdt
            ]
        );
    }
}
