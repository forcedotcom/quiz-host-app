@isTest(isParallel=true)
public class QuizQuestionServiceTest {
    @isTest
    static void getQuestions_works() {
        QuizQuestionService service = new QuizQuestionService();
        Quiz_Question__c question = QuizSessionTestFactory.createQuizQuestion();

        List<Quiz_Question__c> questions = service.getQuestions();

        System.assertEquals(1, questions.size());
        System.assertEquals(question.Id, questions[0].Id);
    }
}
