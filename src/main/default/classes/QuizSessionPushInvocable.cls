public with sharing class QuizSessionPushInvocable {
    @InvocableMethod(label='Push Quiz Session Update')
    public static void invokeQuizSessionPush(
        List<QuizSessionPushInvocableParameters> paramList
    ) {
        for (QuizSessionPushInvocableParameters params : paramList) {
            pushQuizSession(params.phase);
        }
    }

    @future(callout=true)
    private static void pushQuizSession(String phase) {
        QuizSettingsService settingsService = new QuizSettingsService();
        Quiz_Settings__mdt settings = settingsService.get();

        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(settings.Player_App_URL__c + '/api/quiz-sessions');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Api-Key', settings.Quiz_Api_Key__c);
        request.setBody('{ "Phase__c": "' + phase + '" }');

        Http httpClient = new Http();
        HttpResponse response = httpClient.send(request);
        if (response.getStatusCode() != 200) {
            throw new QuizSessionPushInvocableException(
                'Failed to push quiz session update: HTTP' +
                response.getStatusCode() +
                ' ' +
                response.getBody()
            );
        }
    }

    public class QuizSessionPushInvocableException extends Exception {
    }

    public class QuizSessionPushInvocableParameters {
        @InvocableVariable(required=true label='Phase' description='Quiz phase')
        public String phase;
    }
}
