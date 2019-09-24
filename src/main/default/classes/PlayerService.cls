public class PlayerService extends AbstractDataService  {

    public Quiz_Player__c getFromName(String name) {
        return (Quiz_Player__c) getSingleRecord([SELECT Id FROM Quiz_Player__c WHERE Name = :name]);
    }

    public Quiz_Player__c create(String name) {
        Quiz_Player__c player = new Quiz_Player__c(Name = name);
        insert player;
        return player;
    }

    public List<Quiz_Player__c> getPlayersSortedByScore(Integer maxFetchCount) {
        String query = 'SELECT Id, Name, Score__c FROM Quiz_Player__c ORDER BY Score__c DESC';
        if (maxFetchCount != null) {
            query += ' LIMIT ' + maxFetchCount;
        } 

        return Database.query(query);
    }

    public Map<ID, Quiz_Player__c> getPlayers() {
        return new Map<ID, Quiz_Player__c>([SELECT Id, Score__c FROM Quiz_Player__c]);
    }

    public void deleteAnswersAndPlayers() {
        // need delete answers before delete players
        List<Quiz_Answer__c> answers = [SELECT ID FROM Quiz_Answer__c];
        delete answers;

        List<Quiz_Player__c> players = [SELECT ID FROM Quiz_Player__c];
        delete players;
    }

    public void assignRanking() {
        List<Quiz_Player__c> updatedPlayers = getPlayersSortedByScore(null);
        if (updatedPlayers.isEmpty()) {
            return;
        } else {
            // assign first place, regardless of how many records
            updatedPlayers[0].Ranking__c = 1;
            if (updatedPlayers.size() == 1) {
                update updatedPlayers;
                return;
            }
        }

        Integer ranking = 1;
        for (Integer i = 1; i < updatedPlayers.size(); i++) {
            // if previous score differs from current score, increment ranking
            if (updatedPlayers[i-1].Score__c < updatedPlayers[i].Score__c) {
                ranking += 1;
            }
                
            updatedPlayers[i].Ranking__c = ranking;
        }

        update updatedPlayers;        
    }
}
