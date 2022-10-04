@isTest(isParallel=true)
public class QuizPlayerServiceTest {
    @isTest
    static void getFromName_works() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        List<Quiz_Player__c> players = QuizSessionTestFactory.createQuizPlayers(
            session.Id,
            1
        );

        QuizPlayerService playerService = new QuizPlayerService();
        Quiz_Player__c player = playerService.getFromName(
            session.Id,
            QuizSessionTestFactory.PLAYER_NAME_PREFIX + '0'
        );

        System.assertEquals(players[0].Id, player.Id);
    }

    @isTest
    static void assignRanks_works_with_one_player() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        QuizSessionTestFactory.createQuizPlayers(session.Id, 1);

        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanks(session.Id);

        List<Quiz_Player__c> updatedPlayers = [
            SELECT Id, Ranking__c
            FROM Quiz_Player__c
            WITH SECURITY_ENFORCED
        ];
        System.assertEquals(1, updatedPlayers.size());
        System.assertEquals(1, updatedPlayers[0].Ranking__c);
    }

    @isTest
    static void assignRanks_works_with_two_player_same_score() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'one',
            100
        );
        Quiz_Player__c player2 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'two',
            100
        );
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanks(session.Id);

        Integer ranking1 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player1.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();
        Integer ranking2 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player2.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();

        System.assertEquals(1, ranking1);
        System.assertEquals(1, ranking2);
    }

    @isTest
    static void assignRanks_works_with_two_player_different_score() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'one',
            100
        );
        Quiz_Player__c player2 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'two',
            50
        );
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanks(session.Id);

        Integer ranking1 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player1.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();
        Integer ranking2 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player2.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();

        System.assertEquals(1, ranking1);
        System.assertEquals(2, ranking2);
    }

    @isTest
    static void assignRanks_works_with_three_players() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'one',
            100
        );
        Quiz_Player__c player2 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'two',
            100
        );
        Quiz_Player__c player3 = QuizSessionTestFactory.createQuizPlayerWithScore(
            session.Id,
            'three',
            10
        );
        QuizPlayerService playerService = new QuizPlayerService();
        playerService.assignRanks(session.Id);

        Integer ranking1 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player1.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();
        Integer ranking2 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player2.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();
        Integer ranking3 = [
                SELECT Id, Ranking__c
                FROM Quiz_Player__c
                WHERE Id = :player3.Id
                WITH SECURITY_ENFORCED
            ]
            .Ranking__c.intValue();

        System.assertEquals(1, ranking1);
        System.assertEquals(1, ranking2);
        System.assertEquals(2, ranking3);
    }
}
