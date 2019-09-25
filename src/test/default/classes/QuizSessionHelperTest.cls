@isTest 
public with sharing class QuizSessionHelperTest {
    private static Integer NUM_PLAYERS = 150;
    private static String REGISTRATION = QuizSessionService.Phase.Registration.name();
    private static String QUESTION = QuizSessionService.Phase.Question.name();
    private static String POST_QUESTION = QuizSessionService.Phase.PostQuestion.name();
    
    @isTest static void playerAccumulatesScore() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player');
        Quiz_Question__c question1 = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Question__c question2 = QuizSessionTestFactory.createQuizQuestion();
        Quiz_Answer__c quizAnswer1 = QuizSessionTestFactory.createQuizAnswer(player.Id, question1.Id, question1.Correct_Answer__c); 
        Quiz_Answer__c quizAnswer2 = QuizSessionTestFactory.createQuizAnswer(player.Id, question2.Id, question2.Correct_Answer__c); 

        Test.startTest();
        quizSession.Phase__c = POST_QUESTION;
        update quizSession;

        // update quiz session's 'current question
        quizSession.Phase__c = QUESTION;
        quizSession.Current_Question__c = question2.Id;
        update quizSession;
        
        quizSession.Phase__c = POST_QUESTION;
        update quizSession;        
        Test.stopTest();           

        Integer score = [SELECT Id, Score__c FROM Quiz_Player__c WHERE Id = :player.Id].Score__c.intValue();
        System.assertEquals(2000, score);
    }

    @isTest static void changePhaseToRegistrationRemovesPlayersAndAnswers() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player');
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, question.Correct_Answer__c); 

        // change to Registration from non-Registration phase
        quizSession.Phase__c = POST_QUESTION;
        update quizSession;

        Test.startTest();
        quizSession.Phase__c = REGISTRATION;
        update quizSession;
        Test.stopTest();   

        Integer playerCount = [SELECT COUNT() FROM Quiz_Player__c];
        Integer answerCount = [SELECT COUNT() FROM Quiz_Answer__c];
        System.assertEquals(0, playerCount);
        System.assertEquals(0, answerCount);
    }    

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

        List<Quiz_Answer__c> updatedAnswers = [SELECT Id, Score__c FROM Quiz_Answer__c];
        for (Integer i = 1; i <= updatedAnswers.size(); i++) {
            System.assert(updatedAnswers[i-1].Score__c > 0);            
        }
    }    

    @isTest static void millisecondFieldExistsOnAnswer() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player');
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, question.Correct_Answer__c); 

        Decimal numberOfMilliseconds = [SELECT Id, Score__c, Timestamp__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id].Timestamp__c;
        Long baseline = Long.valueOf('1569261277045');
        System.assert(numberOfMilliseconds > baseline);
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

        Integer score = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id].Score__c.intValue();
        System.assertEquals(1000, score);
    }    

    @isTest static void lastAnswerGets500Points() {
        Quiz_Session__c quizSession = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = [SELECT Id, Correct_Answer__c FROM Quiz_Question__c LIMIT 1];        
        Quiz_Player__c player = QuizSessionTestFactory.createQuizPlayer('player1');
        Quiz_Player__c lastPlayer = QuizSessionTestFactory.createQuizPlayer('player2');

        Test.startTest();
        quizSession.Phase__c = POST_QUESTION;
        Quiz_Answer__c quizAnswer = QuizSessionTestFactory.createQuizAnswer(player.Id, question.Id, question.Correct_Answer__c); 
        Quiz_Answer__c lastQuizAnswer = QuizSessionTestFactory.createQuizAnswer(lastPlayer.Id, question.Id, question.Correct_Answer__c); 
        Set<ID> quizAnswerIds = new Set<ID>();
        quizAnswerIds.add(quizAnswer.Id);
        quizAnswerIds.add(lastQuizAnswer.Id);
        update quizSession;
        Test.stopTest();   

        List<Quiz_Answer__c> updatedQuizAnswers = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID IN :quizAnswerIds];
        System.assertEquals(500, updatedQuizAnswers[1].Score__c);
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

        Integer score = [SELECT Id, Score__c FROM Quiz_Player__c WHERE ID = :player.Id].Score__c.intValue();
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

        Integer score = [SELECT Id, Score__c FROM Quiz_Answer__c WHERE ID = :quizAnswer.Id].Score__c.intValue();
        System.assertEquals(0, score);
    }        
}
