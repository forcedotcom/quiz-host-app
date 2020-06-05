global with sharing class QuizAnswer {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global Id playerId { get; set; }
    @AuraEnabled
    global Id questionId { get; set; }
    @AuraEnabled
    global String answer { get; set; }

    global QuizAnswer() {
    }

    global QuizAnswer(Quiz_Answer__c answer) {
        this.id = answer.Id;
        this.playerId = answer.Player__c;
        this.questionId = answer.Question__c;
        this.answer = answer.Answer__c;
    }
}
