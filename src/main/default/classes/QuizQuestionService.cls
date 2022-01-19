public class QuizQuestionService extends QuizAbstractDataService {
    public List<Quiz_Question__c> getQuestions() {
        return [
            SELECT Id, Label__c
            FROM Quiz_Question__c
            WITH SECURITY_ENFORCED
        ];
    }
}
