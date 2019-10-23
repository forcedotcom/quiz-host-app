trigger QuizSessionTrigger on Quiz_Session__c(before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        QuizSessionTriggerHelper.beforeUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        QuizSessionTriggerHelper.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}
