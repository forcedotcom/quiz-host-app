@isTest(isParallel=true)
public class QuizPlayerServiceTest {
    @isTest
    static void onlyPlayerRanksOne() {
        QuizSessionTestFactory.createQuizPlayers(1);

        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanking();

        List<Quiz_Player__c> updatedPlayers = [
            SELECT Id, Ranking__c
            FROM Quiz_Player__c
        ];
        System.assertEquals(1, updatedPlayers.size());
        System.assertEquals(1, updatedPlayers[0].Ranking__c);
    }

    @isTest
    static void twoPlayersSameScoreBothRankOne() {
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'one',
            100
        );
        Quiz_Player__c player2 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'two',
            100
        );
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanking();

        Integer ranking1 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player1.Id
            ]
            .Ranking__c.intValue();
        Integer ranking2 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player2.Id
            ]
            .Ranking__c.intValue();

        System.assertEquals(1, ranking1);
        System.assertEquals(1, ranking2);
    }

    @isTest
    static void twoPlayersDifferentScoreDifferentRanking() {
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'one',
            100
        );
        Quiz_Player__c player2 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'two',
            50
        );
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanking();

        Integer ranking1 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player1.Id
            ]
            .Ranking__c.intValue();
        Integer ranking2 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player2.Id
            ]
            .Ranking__c.intValue();

        System.assertEquals(1, ranking1);
        System.assertEquals(2, ranking2);
    }

    @isTest
    static void threePlayersMixedRanking() {
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'one',
            100
        );
        Quiz_Player__c player2 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'two',
            100
        );
        Quiz_Player__c player3 = QuizSessionTestFactory.createQuizPlayerWithScore(
            'three',
            10
        );
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanking();

        Integer ranking1 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player1.Id
            ]
            .Ranking__c.intValue();
        Integer ranking2 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player2.Id
            ]
            .Ranking__c.intValue();
        Integer ranking3 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player3.Id
            ]
            .Ranking__c.intValue();

        System.assertEquals(1, ranking1);
        System.assertEquals(1, ranking2);
        System.assertEquals(2, ranking3);
    }
}
