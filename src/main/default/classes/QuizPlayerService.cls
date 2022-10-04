public class QuizPlayerService extends QuizAbstractDataService {
    public Quiz_Player__c getFromId(Id playerId) {
        return (Quiz_Player__c) getSingleRecord(
            'Quiz_Player__c',
            [
                SELECT Id, Name, Score__c, Ranking__c, Session__c
                FROM Quiz_Player__c
                WHERE Id = :playerId
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public Quiz_Player__c getFromName(Id sessionId, String name) {
        return (Quiz_Player__c) getSingleRecord(
            'Quiz_Player__c',
            [
                SELECT Id
                FROM Quiz_Player__c
                WHERE Session__c = :sessionId AND Name = :name
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public List<Quiz_Player__c> getPlayersSortedByScore(
        Id sessionId,
        Integer maxFetchCount
    ) {
        String query =
            'SELECT Id, Name, Score__c, Ranking__c' +
            ' FROM Quiz_Player__c' +
            ' WHERE Session__c = \'' +
            sessionId +
            '\'' +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Score__c DESC';
        if (maxFetchCount != null) {
            query += ' LIMIT ' + maxFetchCount;
        }
        return Database.query(query);
    }

    public Map<Id, Quiz_Player__c> getPlayers(Id sessionId) {
        return new Map<Id, Quiz_Player__c>(
            [
                SELECT Id, Score__c
                FROM Quiz_Player__c
                WHERE Session__c = :sessionId
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public void deletePlayers(Id sessionId) {
        delete [
            SELECT Id
            FROM Quiz_Player__c
            WHERE Session__c = :sessionId
            WITH SECURITY_ENFORCED
        ];
    }

    public void assignRanks(Id sessionId) {
        List<Quiz_Player__c> players = getPlayersSortedByScore(sessionId, null);
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
