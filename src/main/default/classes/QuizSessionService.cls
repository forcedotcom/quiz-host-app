public class QuizSessionService extends QuizAbstractDataService {
    public enum Phase {
        Registration,
        PreQuestion,
        Question,
        QuestionResults,
        GameResults
    }

    public Quiz_Session__c getQuizSession() {
        return (Quiz_Session__c) getSingleRecord(
            'Quiz_Session__c',
            [
                SELECT Id, Phase__c, Current_Question__c
                FROM Quiz_Session__c
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public Quiz_Question__c getCurrentQuestion(Id sessionId) {
        Quiz_Session__c session = (Quiz_Session__c) getSingleRecord(
            'Quiz_Session__c',
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
                WITH SECURITY_ENFORCED
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
            WITH SECURITY_ENFORCED
            ORDER BY Question_Index__c
        ];
        for (Quiz_Session_Question__c joinRecord : joinRecords) {
            questions.add(joinRecord.Question__r);
        }
        return questions;
    }

    public void setSessionQuestions(Id sessionId, List<Id> questionIds) {
        // Get session
        Quiz_Session__c session = [
            SELECT Current_Question__c
            FROM Quiz_Session__c
            WHERE Id = :sessionId
            WITH SECURITY_ENFORCED
        ];
        // Overwrite session questions
        delete [
            SELECT Id
            FROM Quiz_Session_Question__c
            WHERE Session__c = :sessionId
            WITH SECURITY_ENFORCED
        ];
        List<Quiz_Session_Question__c> questions = new List<Quiz_Session_Question__c>();
        for (Integer i = 0; i < questionIds.size(); i++) {
            questions.add(
                new Quiz_Session_Question__c(
                    Question__c = questionIds[i],
                    Question_Index__c = i,
                    Session__c = sessionId
                )
            );
        }
        insert questions;
        // Replace current question
        session.Current_Question__c = questionIds[0];
        update session;
    }
}
