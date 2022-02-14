public class QuizSettingsService extends QuizAbstractDataService {
    public Quiz_Settings__mdt get() {
        Quiz_Settings__mdt settings;
        if (Test.isRunningTest()) {
            settings = new Quiz_Settings__mdt(
                Player_App_URL__c = 'https://mock-full.url',
                Player_App_URL_Minified__c = 'https://mock-mini.url',
                Quiz_API_Key__c = 'mock-key',
                Question_Timer__c = 12
            );
        } else {
            settings = (Quiz_Settings__mdt) getSingleRecord(
                'Quiz_Settings__mdt',
                [
                    SELECT
                        Id,
                        Player_App_URL__c,
                        Player_App_URL_Minified__c,
                        Quiz_API_Key__c,
                        Question_Timer__c
                    FROM Quiz_Settings__mdt
                    WITH SECURITY_ENFORCED
                ]
            );
        }
        // Normalize player app URL
        settings.Player_App_URL__c = settings.Player_App_URL__c.removeEnd('/');
        return settings;
    }

    public void checkSettings() {
        // Check for a unique settings record
        Quiz_Settings__mdt settings = this.get();
        // Check that player app can be reached (remote site is configured and URL is valid)
        HttpRequest req = new HttpRequest();
        req.setEndpoint(settings.Player_App_URL__c);
        req.setMethod('GET');
        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() < 200 || res.getStatusCode() > 300) {
            throw new PlayerAppUrlException(
                'Failed to reach player app (HTTP ' +
                res.getStatusCode() +
                '). Check if URL is valid: ' +
                settings.Player_App_URL__c
            );
        }
    }

    public class PlayerAppUrlException extends Exception {
    }
}
