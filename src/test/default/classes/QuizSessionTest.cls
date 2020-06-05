@isTest(isParallel=true)
public class QuizSessionTest {
    @isTest
    static void constructor_works() {
        Quiz_Session__c record = new Quiz_Session__c(Phase__c = 'Registration');

        QuizSession session = new QuizSession(record);

        System.assertEquals(record.Phase__c, session.phase);
    }
}
