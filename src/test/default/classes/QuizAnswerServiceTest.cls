@isTest(isParallel=true)
public class QuizAnswerServiceTest {
    @isTest
    static void getAnswerStats_works() {
        QuizAnswerService service = new QuizAnswerService();
        Quiz_Session__c session = QuizSessionTestFactory.createQuizSession();
        Quiz_Question__c question = session.Current_Question__r;
        List<Quiz_Player__c> players = QuizSessionTestFactory.createQuizPlayers(
            2
        );
        QuizSessionTestFactory.createQuizAnswer(
            players[0].Id,
            question.Id,
            'B'
        );
        QuizSessionTestFactory.createQuizAnswer(
            players[1].Id,
            question.Id,
            'D'
        );

        Test.startTest();
        Map<String, Integer> stats = service.getAnswerStats();
        Test.stopTest();

        System.assertEquals(0, stats.get('A'));
        System.assertEquals(1, stats.get('B'));
        System.assertEquals(0, stats.get('C'));
        System.assertEquals(1, stats.get('D'));
    }
}
