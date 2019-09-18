public class PlayerService extends AbstractDataService  {

    public Quiz_Player__c getFromName(String name) {
        return (Quiz_Player__c) getSingleRecord([SELECT Id FROM Quiz_Player__c WHERE Name = :name]);
    }

    public Quiz_Player__c create(String name) {
        Quiz_Player__c player = new Quiz_Player__c(Name = name);
        insert player;
        return player;
    }

    public List<Quiz_Player__c> getPlayers() {
        return [SELECT ID, Score__c FROM Quiz_Player__c];
    }

    public void deleteAnswersAndPlayers() {
        // need delete answers before delete players
        List<Quiz_Answer__c> answers = [SELECT ID FROM Quiz_Answer__c];
        delete answers;

        List<Quiz_Player__c> players = [SELECT ID FROM Quiz_Player__c];
        delete players;
    }
}
