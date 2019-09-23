trigger QuizAnswerTrigger on Quiz_Answer__c (before insert) {
    for (Quiz_Answer__c answer : Trigger.new) {
        answer.Milliseconds__c = Datetime.now().millisecond();
    }
}