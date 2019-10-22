@isTest(isParallel=true)
public class QuizSessionTriggerHelperTest {
    private static String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name(),
        PHASE_QUESTION = QuizSessionService.Phase.Question.name(),
        PHASE_QUESTION_RESULTS = QuizSessionService.Phase.QuestionResults.name();

    @isTest
    static void changePhaseToRegistrationResetsCurrentQuestion() {
        Test.setMock(
            HttpCalloutMock.class,
            new TestUtils.MockSuccessHttpResponse()
        );

        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question1 = quizSession.Current_Question__r;
        Quiz_Question__c question2 = QuizSessionTestFactory.createQuizQuestion();
        QuizSessionTestFactory.createQuizSessionQuestion(
            quizSession,
            question2,
            1
        );

        quizSession.Current_Question__r = question2;
        quizSession.Phase__c = PHASE_QUESTION;
        update quizSession;

        quizSession.Phase__c = PHASE_REGISTRATION;
        update quizSession;

        Quiz_Session__c updatedSession = [
            SELECT Current_Question__c
            FROM Quiz_Session__c
        ];
        System.assertEquals(question1.Id, updatedSession.Current_Question__c);
    }

    @isTest
    static void changePhaseToRegistrationRemovesPlayersAndAnswers() {
        Test.setMock(
            HttpCalloutMock.class,
            new TestUtils.MockSuccessHttpResponse()
        );

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
}
