@isTest(isParallel=true)
public class QuizQuestionTest {
    @isTest
    static void fromRecordList_works() {
        List<Quiz_Question__c> records = new List<Quiz_Question__c>{
            new Quiz_Question__c(Label__c = 'l1', Answer_A__c = 'aA')
        };

        List<QuizQuestion> questions = QuizQuestion.fromRecordList(records);

        System.assertEquals(records.size(), questions.size());
        System.assertEquals(records[0].Label__c, questions[0].label);
        System.assertEquals(records[0].Answer_A__c, questions[0].answerA);
    }
}
