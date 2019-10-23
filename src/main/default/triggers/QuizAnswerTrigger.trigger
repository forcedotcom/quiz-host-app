trigger QuizAnswerTrigger on Quiz_Answer__c(before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        QuizAnswerTriggerHelper.beforeInsert(Trigger.new);
    }
}
