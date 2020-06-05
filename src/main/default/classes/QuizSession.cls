global with sharing class QuizSession {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String phase { get; set; }
    @AuraEnabled
    global Id questionId { get; set; }

    global QuizSession() {
    }

    global QuizSession(Quiz_Session__c session) {
        this.id = session.Id;
        this.phase = session.Phase__c;
        this.questionId = session.Current_Question__c;
    }
}
