public class PlayerService extends AbstractDataService  {

    public Quiz_Player__c getFromName(String name) {
        return (Quiz_Player__c) getSingleRecord([SELECT Id FROM Quiz_Player__c WHERE Name = :name]);
    }

    public Quiz_Player__c create(String name) {
        Quiz_Player__c player = new Quiz_Player__c(Name = name);
        insert player;
        return player;
    }
}
