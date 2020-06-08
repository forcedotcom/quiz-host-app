global class QuizPostInstallScript implements InstallHandler {
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();

    global void onInstall(InstallContext context) {
        if (context.previousVersion() == null) {
            doFreshInstall();
        }
    }

    private void doFreshInstall() {
        // Insert sample question
        Quiz_Question__c question = new Quiz_Question__c(
            Label__c = 'How many major Salesforce releases are there each year?',
            Answer_A__c = '1',
            Answer_B__c = '2',
            Answer_C__c = '3',
            Answer_D__c = '4',
            Correct_Answer__c = 'C'
        );
        insert question;
        // Insert session
        Quiz_Session__c session = new Quiz_Session__c(
            Phase__c = PHASE_REGISTRATION,
            Current_Question__r = question,
            Current_Question__c = question.Id
        );
        insert session;
        // Add sample question to session
        Quiz_Session_Question__c sessionQuestion = new Quiz_Session_Question__c(
            Session__r = session,
            Session__c = session.Id,
            Question_Index__c = 1,
            Question__r = question,
            Question__c = question.Id
        );
        insert sessionQuestion;
    }
}
