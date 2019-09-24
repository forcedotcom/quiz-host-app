trigger QuizAnswerTrigger on Quiz_Answer__c (before insert) {
    for (Quiz_Answer__c answer : Trigger.new) {
        // # of milliseconds since January 1, 1970, 00:00:00 GMT, ie. 1569261277045
        answer.Timestamp__c = Datetime.now().getTime();
    }
}