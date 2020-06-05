@isTest(isParallel=true)
public class QuizEditorControllerTest {
    @isTest
    static void setSessionQuestions_fails_when_no_session_id() {
        try {
            QuizEditorController.setSessionQuestions(null, new List<Id>());
            // expect to fail
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void setSessionQuestions_fails_when_no_questions() {
        try {
            QuizEditorController.setSessionQuestions(
                'a043N000000pLrVQAU',
                null
            );
            // expect to fail
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @isTest
    static void getSessionQuestionIds_fails_when_no_session_id() {
        try {
            QuizEditorController.getSessionQuestionIds(null);
            // expect to fail
            System.assert(false);
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }
}
