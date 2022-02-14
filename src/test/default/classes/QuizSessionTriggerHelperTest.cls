@isTest(isParallel=true)
public class QuizSessionTriggerHelperTest {
    private static String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_QUESTION = QuizSessionService.Phase.Question.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name();

    @isTest
    static void changePhaseToRegistrationResetsCurrentQuestion() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question1 = session.Current_Question__r;
        Quiz_Question__c question2 = QuizSessionTestFactory.createQuizQuestion();
        QuizSessionTestFactory.createQuizSessionQuestion(session, question2, 1);

        session.Current_Question__r = question2;
        session.Phase__c = PHASE_QUESTION;
        update session;

        session.Phase__c = PHASE_REGISTRATION;
        update session;

        Quiz_Session__c updatedSession = [
            SELECT Current_Question__c
            FROM Quiz_Session__c
            WITH SECURITY_ENFORCED
        ];
        System.assertEquals(question1.Id, updatedSession.Current_Question__c);
    }

    @isTest
    static void changePhaseToRegistrationRemovesPlayersAndAnswers() {
        Test.setMock(
            HttpCalloutMock.class,
            new QuizTestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayers(1)[0];
        QuizSessionTestFactory.createQuizAnswer(
            player.Id,
            question.Id,
            question.Correct_Answer__c
        );

        // change to Registration from non-Registration phase
        session.Phase__c = PHASE_QUESTION;
        update session;

        Test.startTest();
        session.Phase__c = PHASE_REGISTRATION;
        update session;
        Test.stopTest();

        Integer playerCount = [
            SELECT COUNT()
            FROM Quiz_Player__c
            WITH SECURITY_ENFORCED
        ];
        Integer answerCount = [
            SELECT COUNT()
            FROM Quiz_Answer__c
            WITH SECURITY_ENFORCED
        ];
        System.assertEquals(0, playerCount);
        System.assertEquals(0, answerCount);
    }
}
