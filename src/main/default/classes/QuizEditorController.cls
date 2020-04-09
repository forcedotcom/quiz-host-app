public with sharing class QuizEditorController {
    private static final QuizQuestionService questionService = new QuizQuestionService();
    private static final QuizSessionService sessionService = new QuizSessionService();

    @AuraEnabled(cacheable=true)
    public static List<Quiz_Question__c> getAllQuestions() {
        return questionService.getQuestions();
    }

    @AuraEnabled
    public static void setSessionQuestions(Id sessionId, List<Id> questionIds) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        if (questionIds == null) {
            throw new AuraHandledException('Missing questions Ids.');
        }
        sessionService.setSessionQuestions(sessionId, questionIds);
    }

    @AuraEnabled(cacheable=true)
    public static List<Quiz_Question__c> getSessionQuestions(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        return sessionService.getSessionQuestions(sessionId);
    }
}
