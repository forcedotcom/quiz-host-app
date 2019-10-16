@isTest
public with sharing class QuizSessionHelperTest {
    private static Integer NUM_PLAYERS = 150;

    private static String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();
    private static String PHASE_QUESTION = QuizSessionService.Phase.Question.name();
    private static String PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name();

    @isTest
    static void duplicateAnswerNotCreated() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        try {
            Quiz_Answer__c quizAnswer1 = QuizSessionTestFactory.createQuizAnswer(
                player.Id,
                question.Id,
                question.Correct_Answer__c
            );
            Quiz_Answer__c quizAnswer2 = QuizSessionTestFactory.createQuizAnswer(
                player.Id,
                question.Id,
                question.Correct_Answer__c
            );
            // expect to fail
            System.assert(false);
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Duplicate answer'));
            Integer answerCount = [SELECT COUNT() FROM Quiz_Answer__c];
            System.assertEquals(1, answerCount);
        }
    }

    @isTest
    static void playerAccumulatesScore() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        Quiz_Question__c question1 = quizSession.Current_Question__r;
        Quiz_Question__c question2 = QuizSessionTestFactory.createQuizQuestion();
        Quiz_Answer__c quizAnswer1 = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question1.Id,
            question1.Correct_Answer__c
        );

        Test.startTest();
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        update quizSession;

        // update quiz session's 'current question
        quizSession.Phase__c = PHASE_QUESTION;
        quizSession.Current_Question__c = question2.Id;
        update quizSession;

        Quiz_Answer__c quizAnswer2 = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question2.Id,
            question2.Correct_Answer__c
        );
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        update quizSession;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Player__c
                WHERE Id = :player.Id
            ]
            .Score__c.intValue();
        System.assertEquals(2000, score);
    }

    @isTest
    static void changePhaseToRegistrationRemovesPlayersAndAnswers() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            question.Correct_Answer__c
        );

        // change to Registration from non-Registration phase
        quizSession.Phase__c = PHASE_QUESTION;
        update quizSession;

        Test.startTest();
        quizSession.Phase__c = PHASE_REGISTRATION;
        update quizSession;
        Test.stopTest();

        Integer playerCount = [SELECT COUNT() FROM Quiz_Player__c];
        Integer answerCount = [SELECT COUNT() FROM Quiz_Answer__c];
        System.assertEquals(0, playerCount);
        System.assertEquals(0, answerCount);
    }

    @isTest
    static void stressTestCorrectAnswerIncrementScorePlayer() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
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
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        update quizSession;
        Test.stopTest();

        // get answers ordered by oldest first, loop through them to get player Ids
        List<Quiz_Answer__c> updatedAnswers = [
            SELECT Id, Player__c, Score__c
            FROM Quiz_Answer__c
        ];
        Set<Id> updatedPlayerIds = new Set<Id>();
        for (Integer i = 0; i < updatedAnswers.size(); i++) {
            updatedPlayerIds.add(updatedAnswers[i].Player__c);
        }
        List<Quiz_Player__c> updatedPlayers = [
            SELECT Id, Score__c
            FROM Quiz_Player__c
            WHERE Id IN :updatedPlayerIds
        ];
        for (Integer i = 1; i <= updatedPlayers.size(); i++) {
            System.assert(updatedPlayers[i - 1].Score__c > 0);
        }
    }

    @isTest
    static void stressTestCorrectAnswerIncrementScoreAnswer() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
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
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        update quizSession;
        Test.stopTest();

        List<Quiz_Answer__c> updatedAnswers = [
            SELECT Id, Score__c
            FROM Quiz_Answer__c
        ];
        for (Integer i = 1; i <= updatedAnswers.size(); i++) {
            System.assert(updatedAnswers[i - 1].Score__c > 0);
        }
    }

    @isTest
    static void millisecondFieldExistsOnAnswer() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            question.Correct_Answer__c
        );

        Decimal numberOfMilliseconds = [
            SELECT Id, Score__c, Timestamp__c
            FROM Quiz_Answer__c
            WHERE Id = :quizAnswer.Id
        ]
        .Timestamp__c;
        Long baseline = Long.valueOf('1569261277045');
        System.assert(numberOfMilliseconds > baseline);
    }

    @isTest
    static void updateScoreOnAnswerWithFullMarks() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            question.Correct_Answer__c
        );
        update quizSession;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Answer__c
                WHERE Id = :quizAnswer.Id
            ]
            .Score__c.intValue();
        System.assertEquals(1000, score);
    }

    @isTest
    static void lastCorrectAnswerGets500Points() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        List<Quiz_Player__c> players = QuizSessionTestFactory.createQuizPlayers(
            2
        );

        Test.startTest();
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
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
        update quizSession;
        Test.stopTest();

        List<Quiz_Answer__c> updatedQuizAnswers = [
            SELECT Id, Score__c
            FROM Quiz_Answer__c
            WHERE Id IN :quizAnswerIds
        ];
        System.assertEquals(500, updatedQuizAnswers[1].Score__c);
    }

    @isTest
    static void doNotUpdatePlayerScoreIfAnswerWrong() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            'a'
        );
        update quizSession;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Player__c
                WHERE Id = :player.Id
            ]
            .Score__c.intValue();
        System.assertEquals(0, score);
    }

    @isTest
    static void doNotUpdateAnswerScoreIfAnswerWrong() {
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = quizSession.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];

        Test.startTest();
        quizSession.Phase__c = PHASE_QUESTION_RESULTS;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            'a'
        );
        update quizSession;
        Test.stopTest();

        Integer score = [
                SELECT Id, Score__c
                FROM Quiz_Answer__c
                WHERE Id = :quizAnswer.Id
            ]
            .Score__c.intValue();
        System.assertEquals(0, score);
    }

    public class MockSuccessHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }
}
