public class QuizSessionService extends AbstractDataService {

    public Quiz_Session__c getQuizSession() {
        return (Quiz_Session__c) getSingleRecord([SELECT Phase__c, Current_Question__c FROM Quiz_Session__c]);
    }
}
