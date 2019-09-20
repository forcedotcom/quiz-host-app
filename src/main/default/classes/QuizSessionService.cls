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

    public List<Quiz_Question__c> getSessionQuestions(String sessionId) {
        List<Quiz_Question__c> questions = new List<Quiz_Question__c>();
        for (Quiz_Session_Question__c quizSessionQuestion : [SELECT ID, 
            Question__c,  Question_Index__c, Session__c FROM Quiz_Session_Question__c WHERE Session__c = :sessionId]) {
            for (Quiz_Question__c question : [SELECT Name, 
                Answer_A__c, Answer_B__c, Answer_C__c, Answer_D__c, Correct_Answer__c, 
                Label__c FROM Quiz_Question__c WHERE ID=:quizSessionQuestion.Question__c]) {
                questions.add(question);
            }
        }
        return questions;    
    }
}
