@isTest(isParallel=true)
public class QuizPostInstallScriptTest {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();

    @isTest
    static void freshInstall_works() {
        Test.testInstall(new QuizPostInstallScript(), null);

        // Check for question
        List<Quiz_Question__c> questions = [SELECT Id FROM Quiz_Question__c];
        System.assertEquals(1, questions.size(), 'Question not found');
        Quiz_Question__c question = questions[0];
        // Check for session
        List<Quiz_Session__c> sessions = [
            SELECT Id, Phase__c, Current_Question__c
            FROM Quiz_Session__c
            WITH SECURITY_ENFORCED
        ];
        System.assertEquals(1, sessions.size(), 'Session not found');
        Quiz_Session__c session = sessions[0];
        System.assertEquals(PHASE_REGISTRATION, session.Phase__c);
        System.assertEquals(question.Id, session.Current_Question__c);
        // Check for session question
        List<Quiz_Session_Question__c> sessionQuestions = [
            SELECT Question__c
            FROM Quiz_Session_Question__c
            WITH SECURITY_ENFORCED
        ];
        System.assertEquals(
            1,
            sessionQuestions.size(),
            'Session question not found'
        );
        Quiz_Session_Question__c sessionQuestion = sessionQuestions[0];
        System.assertEquals(question.Id, sessionQuestion.Question__c);
    }
}
