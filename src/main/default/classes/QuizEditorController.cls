public with sharing class QuizEditorController {
    private static final QuizQuestionService questionService = new QuizQuestionService();
    private static final QuizSessionService sessionService = new QuizSessionService();

    @AuraEnabled(cacheable=true)
    public static List<QuizQuestion> getAllQuestions() {
        List<Quiz_Question__c> questions = questionService.getQuestions();
        return QuizQuestion.fromRecordList(questions);
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
    public static List<Id> getSessionQuestionIds(Id sessionId) {
        if (sessionId == null) {
            throw new AuraHandledException('Missing session Id.');
        }
        List<Quiz_Question__c> questions = sessionService.getSessionQuestions(
            sessionId
        );
        List<Id> questionIds = new List<Id>();
        for (Quiz_Question__c question : questions) {
            questionIds.add(question.Id);
        }
        return questionIds;
    }
}
