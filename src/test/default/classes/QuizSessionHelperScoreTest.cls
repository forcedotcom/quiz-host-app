@isTest(isParallel=true)
public class QuizSessionHelperScoreTest {
    @isTest
    static void noDecimalPlaces() {
        QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
        Long score = quizSessionHelper.computeScore(5, 1, 17);
        System.assertEquals(882, score);
    }

    @isTest
    static void maximumScoreWhereMaxIsMin() {
        QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
        Long score = quizSessionHelper.computeScore(1, 1, 0);
        System.assertEquals(1000, score);
    }

    @isTest
    static void minimumScore() {
        QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
        Long score = quizSessionHelper.computeScore(1, 1, 10);
        System.assertEquals(1000, score);
    }

    @isTest
    static void mediumScore() {
        QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
        Long score = quizSessionHelper.computeScore(10, 1, 10);
        System.assertEquals(550, score);
    }

    @isTest
    static void maximumScore() {
        QuizSessionHelper quizSessionHelper = new QuizSessionHelper();
        Long score = quizSessionHelper.computeScore(10, 1, 9);
        System.assertEquals(500, score);
    }
}
