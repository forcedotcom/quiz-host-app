trigger QuizSessionTrigger on Quiz_Session__c (after update) {
    Boolean deletePlayer = false;
    for (Quiz_Session__c updatedQS : Trigger.new) {
        Quiz_Session__c oldQS = Trigger.oldMap.get(updatedQS.Id);
        if (oldQS.Phase__c != updatedQS.Phase__c && updatedQS.Phase__c == 'Registration') {
            deletePlayer = true;
        }
    }
    if (deletePlayer) {
        // need delete answers before delete players
        List<Quiz_Answer__c> answers = [SELECT ID FROM Quiz_Answer__c];
        delete answers;

        List<Quiz_Player__c> players = [SELECT ID FROM Quiz_Player__c];
        delete players;
    }
}