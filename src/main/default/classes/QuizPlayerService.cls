public class QuizPlayerService extends QuizAbstractDataService {
    public Quiz_Player__c getFromId(Id playerId) {
        return (Quiz_Player__c) getSingleRecord(
            'Quiz_Player__c',
            [
                SELECT Id, Name, Score__c, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :playerId
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public Quiz_Player__c getFromName(String name) {
        return (Quiz_Player__c) getSingleRecord(
            'Quiz_Player__c',
            [
                SELECT Id
                FROM Quiz_Player__c
                WHERE Name = :name
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public List<Quiz_Player__c> getPlayersSortedByScore(Integer maxFetchCount) {
        String query = 'SELECT Id, Name, Score__c, Ranking__c FROM Quiz_Player__c WITH SECURITY_ENFORCED ORDER BY Score__c DESC';
        if (maxFetchCount != null) {
            query += ' LIMIT ' + maxFetchCount;
        }
        return Database.query(query);
    }

    public Map<Id, Quiz_Player__c> getPlayers() {
        return new Map<Id, Quiz_Player__c>(
            [SELECT Id, Score__c FROM Quiz_Player__c WITH SECURITY_ENFORCED]
        );
    }

    public void deleteAnswersAndPlayers() {
        delete [SELECT Id FROM Quiz_Answer__c WITH SECURITY_ENFORCED];
        delete [SELECT Id FROM Quiz_Player__c WITH SECURITY_ENFORCED];
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
