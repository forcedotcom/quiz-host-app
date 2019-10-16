public class QuizSettingsService extends AbstractDataService {
    public Quiz_Settings__mdt get() {
        return (Quiz_Settings__mdt) getSingleRecord(
            [
                SELECT Id, Player_App_URL__c, Quiz_API_Key__c
                FROM Quiz_Settings__mdt
            ]
        );
    }
}
