public class QuizSessionService extends AbstractDataService {
    public enum Phase {
        Registration,
        PreQuestion,
        Question,
        QuestionResults,
        GameResults
    }

    public Map<String, Integer> getAnswerMap(ID sessionId) {
        Map<String, Integer> answerMap = new Map<String, Integer>();
        List<AggregateResult> answerCount = [
            SELECT Answer__c, COUNT(ID)
            FROM Quiz_Answer__c
            WHERE Question__c = :sessionId
            GROUP BY Answer__c
        ];
        for (AggregateResult answerRes : answerCount) {
            answerMap.put(
                answerRes.get('Answer__c').toString(),
                Integer.valueOf(answerRes.get('expr0'))
            );
        }

        return answerMap;
    }

    public Quiz_Session__c getQuizSession() {
        return (Quiz_Session__c) getSingleRecord(
            [SELECT Id, Phase__c, Current_Question__c FROM Quiz_Session__c]
        );
    }

    public Quiz_Question__c getCurrentQuestion(Id sessionId) {
        Quiz_Session__c session = (Quiz_Session__c) getSingleRecord(
            [
                SELECT
                    Current_Question__r.Id,
                    Current_Question__r.Label__c,
                    Current_Question__r.Answer_A__c,
                    Current_Question__r.Answer_B__c,
                    Current_Question__r.Answer_C__c,
                    Current_Question__r.Answer_D__c,
                    Current_Question__r.Correct_Answer__c
                FROM Quiz_Session__c
                WHERE Id = :sessionId
            ]
        );
        return session.Current_Question__r;
    }

    public List<Quiz_Question__c> getSessionQuestions(Id sessionId) {
        List<Quiz_Question__c> questions = new List<Quiz_Question__c>();
        List<Quiz_Session_Question__c> joinRecords = [
            SELECT
                Id,
                Question__r.Id,
                Question__r.Label__c,
                Question__r.Answer_A__c,
                Question__r.Answer_B__c,
                Question__r.Answer_C__c,
                Question__r.Answer_D__c,
                Question__r.Correct_Answer__c
            FROM Quiz_Session_Question__c
            WHERE Session__c = :sessionId
            ORDER BY Question_Index__c
        ];
        for (Quiz_Session_Question__c joinRecord : joinRecords) {
            questions.add(joinRecord.Question__r);
        }
        return questions;
    }
}
