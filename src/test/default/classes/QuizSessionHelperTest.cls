@isTest 
public with sharing class QuizSessionHelperTest {
    private static Integer NUM_PLAYERS = 150;
    private static String POST_QUESTION = 'PostQuestion';
    
    @isTest static void stressTestCorrectAnswerIncrementScorePlayer() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1]; 
        List<Quiz_Player__c> players = new List<Quiz_Player__c>();
        List<Quiz_Answer__c> answers = new List<Quiz_Answer__c>();

        for (Integer j=0;j<NUM_PLAYERS;j++) {      
            players.add(new Quiz_Player__c(
                Name = 'player' + j
            ));
        }
        insert players;

        for (Integer j=0;j<NUM_PLAYERS;j++) {               
            answers.add(new Quiz_Answer__c(
                Player__c = players[j].Id, 
                Question__c = question.Id, 
                Answer__c = question.Correct_Answer__c
            )); 
        }        

        Test.startTest();
        insert answers;
        quizSession.Phase__c = POST_QUESTION;
        update quizSession;
        Test.stopTest();   

        System.assertEquals(POST_QUESTION, quizSession.Phase__c);
        // get answers ordered by oldest first, loop through them to get player IDs
        List<Quiz_Answer__c> updatedAnswers = [SELECT Id, Player__c, Score__c FROM Quiz_Answer__c];
        Set<ID> updatedPlayerIds = new Set<ID>();
        for (Integer i = 0; i < updatedAnswers.size(); i++) {
            updatedPlayerIds.add(updatedAnswers[i].Player__c);
        }
        List<Quiz_Player__c> updatedPlayers = [SELECT Id, Score__c FROM Quiz_Player__c WHERE Id IN :updatedPlayerIds];
        for (Integer i = 1; i <= updatedPlayers.size(); i++) {
            System.assert(updatedPlayers[i-1].Score__c > 0);            
        }        
    }

    @isTest static void stressTestCorrectAnswerIncrementScoreAnswer() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1]; 
        Integer NUM_PLAYERS = 150;
        List<Quiz_Player__c> players = new List<Quiz_Player__c>();
        List<Quiz_Answer__c> answers = new List<Quiz_Answer__c>();

        for (Integer j=0;j<NUM_PLAYERS;j++) {      
            players.add(new Quiz_Player__c(
                Name = 'player' + j
            ));
        }
        insert players;

        for (Integer j=0;j<NUM_PLAYERS;j++) {               
            answers.add(new Quiz_Answer__c(
                Player__c = players[j].Id, 
                Question__c = question.Id, 
                Answer__c = question.Correct_Answer__c
            )); 
        }        

        Test.startTest();
        insert answers;
        quizSession.Phase__c = POST_QUESTION;
        update quizSession;
        Test.stopTest();   

        System.assertEquals(POST_QUESTION, quizSession.Phase__c);
        List<Quiz_Answer__c> updatedAnswers = [SELECT Id, Score__c FROM Quiz_Answer__c];
        for (Integer i = 1; i <= updatedAnswers.size(); i++) {
            System.assert(updatedAnswers[i-1].Score__c > 0);            
        }
    }    

    @isTest static void updateScoreOnAnswerWithFullMarks() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player');

        Test.startTest();
        quizSession.Phase__c = POST_QUESTION;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, question.Correct_Answer__c); 
        update quizSession;
        Test.stopTest();   

        System.assertEquals(POST_QUESTION, quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(1000, score);
    }    

    @isTest static void doNotUpdatePlayerScoreIfAnswerWrong() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player');

        Test.startTest();
        quizSession.Phase__c = POST_QUESTION;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, 'a'); 
        update quizSession;
        Test.stopTest();   

        System.assertEquals(POST_QUESTION, quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Player__c WHERE ID = :player.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(0, score);
    }

    @isTest static void doNotUpdateAnswerScoreIfAnswerWrong() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player');

        Test.startTest();
        quizSession.Phase__c = POST_QUESTION;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, 'a'); 
        update quizSession;
        Test.stopTest();        

        System.assertEquals(POST_QUESTION, quizSession.Phase__c);
        Integer score = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id LIMIT 1].Score__c.intValue();
        System.assertEquals(0, score);
    }        
}
