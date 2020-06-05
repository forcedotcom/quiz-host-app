@isTest(isParallel=true)
public class QuizPlayerTest {
    @isTest
    static void fromRecordList_works() {
        List<Quiz_Player__c> records = new List<Quiz_Player__c>{
            new Quiz_Player__c(Name = 'n1')
        };

        List<QuizPlayer> players = QuizPlayer.fromRecordList(records);

        System.assertEquals(records.size(), players.size());
        System.assertEquals(records[0].Name, players[0].name);
    }
}
