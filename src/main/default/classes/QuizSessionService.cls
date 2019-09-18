public class QuizSessionService extends AbstractDataService {

    public enum Phase {
        Registration,
        PreQuestion,
        Question,
        PostQuestion,
        QuestionResults,
        GameResults
    }

    public Quiz_Session__c getQuizSession() {
        return (Quiz_Session__c) getSingleRecord([SELECT Phase__c, Current_Question__c FROM Quiz_Session__c]);
    }
    
    public Quiz_Question__c getCurrentQuestion(String sessionId) {
        Quiz_Session__c quizSession = getQuizSession();
        String currentQuestionID = quizSession.Current_Question__c;        
        return [SELECT Id, Name, Correct_Answer__c FROM Quiz_Question__c WHERE Id =: currentQuestionID];
    }
}
