@isTest
public with sharing class AnswerServiceTest {
    private static String QUESTION = QuizSessionService.Phase.Question.name();

    @isTest static void getFromPlayerThrowsNoRecordFoundException() {    
        AnswerService answerService = new AnswerService();
        Quiz_Question__c question = QuizSessionTestFactory.createQuizQuestion();        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('1');
        try {
            answerService.getFromPlayer(player.Id, question.Id);
            System.assert(false);
        } catch(AbstractDataService.NoRecordFoundException e) {}       

        Integer answerCount = [SELECT COUNT() FROM Quiz_Answer__c];        
        System.assertEquals(0, answerCount);
    }

    @isTest static void duplicateCallsToCreateFails() {    
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        quizSession.Phase__c = QUESTION;
        update quizSession;
        AnswerService answerService = new AnswerService();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('1');
        try {
            answerService.create(player.Id, question.Correct_Answer__c);
            answerService.create(player.Id, question.Correct_Answer__c);
        } catch(AnswerService.DuplicateAnswerException e) {}
        
        Integer answerCount = [SELECT COUNT() FROM Quiz_Answer__c];        
        System.assertEquals(1, answerCount);
    }    
    
    @isTest static void getAfterCreateReturnsRecord() {    
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        quizSession.Phase__c = QUESTION;
        update quizSession;
        AnswerService answerService = new AnswerService();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('1');
        try {
            answerService.create(player.Id, question.Correct_Answer__c);
            Quiz_Answer__c quizAnswer = answerService.getFromPlayer(player.Id, question.Id);            
            System.assert(quizAnswer.Player__c == player.Id);
        } catch(AnswerService.DuplicateAnswerException e) {}     
    }        
}
