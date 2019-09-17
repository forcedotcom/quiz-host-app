public with sharing class QuizComponentService {
    @AuraEnabled(cacheable=true)
    public static List<Quiz_Question__c> getQuestionList() {
        List<Quiz_Question__c> questions = new List<Quiz_Question__c>();
        for (Quiz_Session_Question__c quizSessionQuestion : [SELECT ID, 
            Question__c,  Question_Index__c, Session__c FROM Quiz_Session_Question__c]) {
            for (Quiz_Question__c question : [SELECT Name, 
                Answer_A__c, Answer_B__c, Answer_C__c, Answer_D__c, Correct_Answer__c, 
                Label__c FROM Quiz_Question__c WHERE ID=:quizSessionQuestion.Question__c]) {
                questions.add(question);
            }
        }
        return questions;
    }

    @AuraEnabled(cacheable=true)
    public static Quiz_Session__c getQuizSession() {
        Quiz_Session__c quizSession = [SELECT ID, Phase__c FROM Quiz_Session__c];        
        return quizSession;
    }     
}
