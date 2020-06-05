global with sharing class QuizSettings {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String playerAppUrl { get; set; }
    @AuraEnabled
    global String playerAppUrlMinified { get; set; }
    @AuraEnabled
    global String quizApiKey { get; set; }
    @AuraEnabled
    global Decimal questionTimer { get; set; }

    global QuizSettings() {
    }

    global QuizSettings(Quiz_Settings__mdt settings) {
        this.id = settings.Id;
        this.playerAppUrl = settings.Player_App_URL__c;
        this.playerAppUrlMinified = settings.Player_App_URL_Minified__c;
        this.quizApiKey = settings.Quiz_API_Key__c;
        this.questionTimer = settings.Question_Timer__c;
    }
}
