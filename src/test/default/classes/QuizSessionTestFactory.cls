@isTest
public with sharing class QuizSessionTestFactory {
    public static Quiz_Session__c createQuizSession() {
        // create one quiz session with all the relevant records
        Quiz_Question__c question = createQuizQuestion();
        Quiz_Session__c quizSession = new Quiz_Session__c(
            Phase__c = 'Registration',
            Current_Question__c = question.Id
        );        
        insert quizSession;
        Quiz_Session_Question__c quizSessionQuestion = createQuizSessionQuestion(quizSession.Id, question.Id);
        return quizSession;
    }

    public static Quiz_Question__c createQuizQuestion() {
        Quiz_Question__c question = new Quiz_Question__c(
                Label__c = 'What does SLDS stand for?',
                Answer_A__c = 'Super Light Debugging Solution',
                Answer_B__c = 'Salesforce Lightning Design System',
                Answer_C__c = 'Salesforce Limited Design System',
                Answer_D__c = 'Salesforce Lightning Design Solution',
                Correct_Answer__c = 'b'
        );
        insert question;
        return question;
    }    

    public static Quiz_Player__c createQuizPlayerWithScore(String name, Integer Score) {
        Quiz_Player__c player1 = new Quiz_Player__c(
            Name = name,
            Score__c = score
        );            
        insert player1;
        return player1;
    }        

    public static Quiz_Player__c createQuizPlayer(String name) {
        Quiz_Player__c player1 = new Quiz_Player__c(
            Name = name
        );            
        insert player1;
        return player1;
    }        

    public static Quiz_Answer__c createQuizAnswer(
        String playerId, String questionId, String answer) {
        Quiz_Answer__c answer1 = new Quiz_Answer__c(
            Player__c = playerId, 
            Question__c = questionId, 
            Answer__c = answer
        );
        insert answer1;
        return answer1;
    }

    public static Quiz_Session_Question__c createQuizSessionQuestion(String sessionId, String questionId) {
        Quiz_Session_Question__c quizSessionQuestion1 = new Quiz_Session_Question__c(
            Session__c = sessionId,
            Question_Index__c = 0,
            Question__c = questionId
        );    
        insert quizSessionQuestion1;
        return quizSessionQuestion1;
    }
}
