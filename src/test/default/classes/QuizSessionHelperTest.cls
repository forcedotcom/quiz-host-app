@isTest(isParallel=true)
public class QuizSessionHelperTest {
    private static Integer NUM_PLAYERS = 150;

    private static String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_QUESTION = QuizSessionService.Phase.Question.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name();

    @isTest
    static void playerAccumulatesScore() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        Quiz_Question__c question1 = session.Current_Question__r;
        Quiz_Question__c question2 = QuizSessionTestFactory.createQuizQuestion();
        Quiz_Answer__c quizAnswer1 = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question1.Id,
            question1.Correct_Answer__c
        );

        Test.startTest();
        session.Phase__c = PHASE_QUESTION_RESULTS;
        update session;

        // update quiz session's 'current question
        session.Phase__c = PHASE_QUESTION;
        session.Current_Question__c = question2.Id;
        update session;

        Quiz_Answer__c quizAnswer2 = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question2.Id,
            question2.Correct_Answer__c
        );
        session.Phase__c = PHASE_QUESTION_RESULTS;
        update session;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Player__c
                WHERE Id = :player.Id
                WITH SECURITY_ENFORCED
            ]
            .Score__c.intValue();
        System.assertEquals(2000, score);
    }

    @isTest
    static void stressTestCorrectAnswerIncrementScorePlayer() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        List<Quiz_Player__c> players = QuizSessionTestFactory.createQuizPlayers(
            NUM_PLAYERS
        );
        List<Quiz_Answer__c> answers = new List<Quiz_Answer__c>();

        for (Integer j = 0; j < NUM_PLAYERS; j++) {
            answers.add(
                new Quiz_Answer__c(
                    Player__c = players[j].Id,
                    Question__c = question.Id,
                    Answer__c = question.Correct_Answer__c
                )
            );
        }

        Test.startTest();
        insert answers;
        session.Phase__c = PHASE_QUESTION_RESULTS;
        update session;
        Test.stopTest();

        // get answers ordered by oldest first, loop through them to get player Ids
        List<Quiz_Answer__c> updatedAnswers = [
            SELECT Id, Player__c, Score__c
            FROM Quiz_Answer__c
            WITH SECURITY_ENFORCED
        ];
        Set<Id> updatedPlayerIds = new Set<Id>();
        for (Integer i = 0; i < updatedAnswers.size(); i++) {
            updatedPlayerIds.add(updatedAnswers[i].Player__c);
        }
        List<Quiz_Player__c> updatedPlayers = [
            SELECT Id, Score__c
            FROM Quiz_Player__c
            WHERE Id IN :updatedPlayerIds
            WITH SECURITY_ENFORCED
        ];
        for (Integer i = 1; i <= updatedPlayers.size(); i++) {
            System.assert(updatedPlayers[i - 1].Score__c > 0);
        }
    }

    @isTest
    static void stressTestCorrectAnswerIncrementScoreAnswer() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        List<Quiz_Player__c> players = QuizSessionTestFactory.createQuizPlayers(
            NUM_PLAYERS
        );
        List<Quiz_Answer__c> answers = new List<Quiz_Answer__c>();

        for (Integer j = 0; j < NUM_PLAYERS; j++) {
            answers.add(
                new Quiz_Answer__c(
                    Player__c = players[j].Id,
                    Question__c = question.Id,
                    Answer__c = question.Correct_Answer__c
                )
            );
        }

        Test.startTest();
        insert answers;
        session.Phase__c = PHASE_QUESTION_RESULTS;
        update session;
        Test.stopTest();

        List<Quiz_Answer__c> updatedAnswers = [
            SELECT Id, Score__c
            FROM Quiz_Answer__c
            WITH SECURITY_ENFORCED
        ];
        for (Integer i = 1; i <= updatedAnswers.size(); i++) {
            System.assert(updatedAnswers[i - 1].Score__c > 0);
        }
    }

    @isTest
    static void updateScoreOnAnswerWithFullMarks() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        session.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            question.Correct_Answer__c
        );
        update session;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Answer__c
                WHERE Id = :quizAnswer.Id
                WITH SECURITY_ENFORCED
            ]
            .Score__c.intValue();
        System.assertEquals(1000, score);
    }

    @isTest
    static void lastCorrectAnswerGets500Points() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        List<Quiz_Player__c> players = QuizSessionTestFactory.createQuizPlayers(
            2
        );

        Test.startTest();
        session.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            players[0].Id,
            question.Id,
            question.Correct_Answer__c
        );
        Quiz_Answer__c lastQuizAnswer = QuizSessionTestFactory.createQuizAnswer(
            players[1].Id,
            question.Id,
            question.Correct_Answer__c
        );
        Set<Id> quizAnswerIds = new Set<Id>();
        quizAnswerIds.add(quizAnswer.Id);
        quizAnswerIds.add(lastQuizAnswer.Id);
        update session;
        Test.stopTest();

        List<Quiz_Answer__c> updatedQuizAnswers = [
            SELECT Id, Score__c
            FROM Quiz_Answer__c
            WHERE Id IN :quizAnswerIds
            WITH SECURITY_ENFORCED
        ];
        System.assertEquals(500, updatedQuizAnswers[1].Score__c);
    }

    @isTest
    static void doNotUpdatePlayerScoreIfAnswerWrong() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        session.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            'a'
        );
        update session;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Player__c
                WHERE Id = :player.Id
                WITH SECURITY_ENFORCED
            ]
            .Score__c.intValue();
        System.assertEquals(0, score);
    }

    @isTest
    static void doNotUpdateAnswerScoreIfAnswerWrong() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        session.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            'a'
        );
        update session;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Answer__c
                WHERE Id = :quizAnswer.Id
                WITH SECURITY_ENFORCED
            ]
            .Score__c.intValue();
        System.assertEquals(0, score);
    }
}
