@isTest(isParallel=true)
public class QuizAnswerTriggerHelpTest {
    @isTest
    static void duplicateAnswerNotCreated() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
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
            Integer answerCount = [
                SELECT COUNT()
                FROM Quiz_Answer__c
                WITH SECURITY_ENFORCED
            ];
            System.assertEquals(1, answerCount);
        }
    }

    @isTest
    static void millisecondFieldExistsOnAnswer() {
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
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
            WITH SECURITY_ENFORCED
        ]
        .Timestamp__c;
        Long baseline = Long.valueOf('1569261277045');
        System.assert(numberOfMilliseconds > baseline);
    }
}
