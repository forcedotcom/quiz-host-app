@isTest(isParallel=true)
public class QuizSessionHelperScoreTest {
    private final static QuizSessionHelper quizSessionHelper = new QuizSessionHelper();

    @isTest
    static void noDecimalPlaces() {
        Long score = quizSessionHelper.computeScore(5, 1, 17);
        System.assertEquals(882, score);
    }

    @isTest
    static void maximumScoreWhereMaxIsMin() {
        Long score = quizSessionHelper.computeScore(1, 1, 0);
        System.assertEquals(1000, score);
    }

    @isTest
    static void minimumScore() {
        Long score = quizSessionHelper.computeScore(1, 1, 10);
        System.assertEquals(1000, score);
    }

    @isTest
    static void mediumScore() {
        Long score = quizSessionHelper.computeScore(10, 1, 10);
        System.assertEquals(550, score);
    }

    @isTest
    static void maximumScore() {
        Long score = quizSessionHelper.computeScore(10, 1, 9);
        System.assertEquals(500, score);
    }
}
