public class AnswerService extends AbstractDataService {

    private static QuizSessionService sessionService = new QuizSessionService();

    public Quiz_Answer__c create(Id playerId, String answer) {
        // Check game phase and question
        Quiz_Session__c session = sessionService.getQuizSession();
        if (session.Phase__c != QuizSessionService.Phase.Question.name()) {
            throw new InvalidPhaseException();
        }
        Id questionId = session.Current_Question__c;

        // Check for duplicate answer from player
        try {
            getFromPlayer(playerId, questionId);
            throw new DuplicateAnswerException();
        } catch (NoRecordFoundException e) {}

        // Save answer
        Quiz_Answer__c answerRecord = new Quiz_Answer__c(Player__c = playerId, Question__c = questionId, Answer__c=  answer);
        insert answerRecord;
        return answerRecord;
    }

    public Quiz_Answer__c getFromPlayer(Id playerId, Id questionId) {
        return (Quiz_Answer__c) getSingleRecord([SELECT Id, Player__c, Question__c, Answer__c FROM Quiz_Answer__c WHERE Player__c = :playerId AND Question__c = :questionId]);
    }

    public class InvalidPhaseException extends Exception {}
    public class DuplicateAnswerException extends Exception {}
}
