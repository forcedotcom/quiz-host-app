@isTest 
public with sharing class QuizSessionHelperTest {
    
    @isTest static void quizSessionStartsWithRegistration() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        List<Quiz_Question__c> questions = new List<Quiz_Question__c>();

        questions = [SELECT Id FROM Quiz_Question__c];
        System.assert(questions.size() > 0);
        System.assertEquals('Registration', quizSession.Phase__c);
    }

    @isTest static void playerCreatedWithZeroScore() {
        List<Quiz_Player__c> players = new List<Quiz_Player__c>();
        Quiz_Player__c player1 = QuizSessionTestFactory.createQuizPlayer();

        players = [SELECT Id FROM Quiz_Player__c];
        System.assert(players.size() > 0);
        System.assertEquals(0, player1.Score__c);
    }      

    @isTest static void updateScoreOnPlayerWithFullMarks() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer();

        Test.startTest();
        quizSession.Phase__c = 'PostQuestion';
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, question.Correct_Answer__c); 
        update quizSession;
        Test.stopTest();   

        System.assertEquals('PostQuestion', quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Player__c WHERE ID = :player.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(1000, score);
    }

    @isTest static void updateScoreOnAnswerWithFullMarks() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer();

        Test.startTest();
        quizSession.Phase__c = 'PostQuestion';
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, question.Correct_Answer__c); 
        update quizSession;
        Test.stopTest();   

        System.assertEquals('PostQuestion', quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(1000, score);
    }    

    @isTest static void doNotUpdatePlayerScoreIfAnswerWrong() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer();

        Test.startTest();
        quizSession.Phase__c = 'PostQuestion';
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, 'a'); 
        update quizSession;
        Test.stopTest();   

        System.assertEquals('PostQuestion', quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Player__c WHERE ID = :player.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(0, score);
    }

    @isTest static void doNotUpdateAnswerScoreIfAnswerWrong() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer();

        Test.startTest();
        quizSession.Phase__c = 'PostQuestion';
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, 'a'); 
        update quizSession;
        Test.stopTest();        

        System.assertEquals('PostQuestion', quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(0, score);
    }        
}
