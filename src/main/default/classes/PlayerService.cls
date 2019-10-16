public class PlayerService extends AbstractDataService {
    public Quiz_Player__c getFromName(String name) {
        return (Quiz_Player__c) getSingleRecord(
            [SELECT Id FROM Quiz_Player__c WHERE Name = :name]
        );
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

    public Map<Id, Quiz_Player__c> getPlayers() {
        return new Map<Id, Quiz_Player__c>(
            [SELECT Id, Score__c FROM Quiz_Player__c]
        );
    }

    public void deleteAnswersAndPlayers() {
        delete [SELECT Id FROM Quiz_Answer__c];
        delete [SELECT Id FROM Quiz_Player__c];
    }

    public void assignRanking() {
        List<Quiz_Player__c> players = getPlayersSortedByScore(null);
        Decimal lastScore = 9223372036854775807L; // Long max value
        Integer rank = 0;
        for (Quiz_Player__c player : players) {
            // if previous score is larger than current score, increment rank
            if (lastScore > player.Score__c) {
                rank++;
            }
            player.Ranking__c = rank;
            lastScore = player.Score__c;
        }
        update players;
    }
}
