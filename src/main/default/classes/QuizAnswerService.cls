public class QuizAnswerService extends QuizAbstractDataService {
    private static final QuizSessionService sessionService = new QuizSessionService();
    private static final QuizPlayerService playerService = new QuizPlayerService();

    public PlayerStats getPlayerAnswerStats(Id playerId) {
        Quiz_Player__c player = playerService.getFromId(playerId);
        List<Quiz_Answer__c> allAnswersFromPlayer = [
            SELECT Player__c, Score__c, IsCorrect__c
            FROM Quiz_Answer__c
            WHERE Player__c = :playerId
            WITH SECURITY_ENFORCED
        ];
        Integer correctCount = 0;
        for (Quiz_Answer__c answerRes : allAnswersFromPlayer) {
            if (answerRes.IsCorrect__c) {
                correctCount++;
            }
        }
        Integer totalCount = allAnswersFromPlayer.size();
        return new PlayerStats(
            totalCount - correctCount,
            correctCount,
            totalCount,
            player.Score__c,
            player.Ranking__c.intValue(),
            player.Name
        );
    }

    public Map<String, Integer> getAnswerStats() {
        Quiz_Session__c session = sessionService.getQuizSession();
        Id questionId = session.Current_Question__c;
        Map<String, Integer> answerMap = new Map<String, Integer>{
            'A' => 0,
            'B' => 0,
            'C' => 0,
            'D' => 0
        };
        List<AggregateResult> answerCount = [
            SELECT Answer__c answer, COUNT(Id)
            FROM Quiz_Answer__c
            WHERE Question__c = :questionId
            WITH SECURITY_ENFORCED
            GROUP BY Answer__c
        ];
        for (AggregateResult answerRes : answerCount) {
            answerMap.put(
                answerRes.get('answer').toString(),
                Integer.valueOf(answerRes.get('expr0'))
            );
        }
        return answerMap;
    }

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
        } catch (NoRecordFoundException e) {
        }

        // Save answer
        Quiz_Answer__c answerRecord = new Quiz_Answer__c(
            Player__c = playerId,
            Question__c = questionId,
            Answer__c = answer
        );
        insert answerRecord;
        return answerRecord;
    }

    public Set<Id> getUniquePlayerIds(List<Quiz_Answer__c> answers) {
        Set<Id> playerIds = new Set<Id>();
        for (Quiz_Answer__c answer : answers) {
            if (!playerIds.contains(answer.Player__c)) {
                playerIds.add(answer.Player__c);
            }
        }
        return playerIds;
    }

    public Map<Id, Id> getPlayerQuestionMapping(Set<Id> playerIds) {
        Map<Id, Id> mapPlayerQuestion = new Map<Id, Id>();
        List<Quiz_Answer__c> allAnswers = [
            SELECT Id, Player__c, Question__c
            FROM Quiz_Answer__c
            WHERE Player__c IN :playerIds
            WITH SECURITY_ENFORCED
            FOR UPDATE
        ];
        for (Quiz_Answer__c answer : allAnswers) {
            mapPlayerQuestion.put(answer.Player__c, answer.Question__c);
        }
        return mapPlayerQuestion;
    }

    // Gets correct answers ordered by oldest records first
    public List<Quiz_Answer__c> getCorrectAnswers(Quiz_Question__c question) {
        return [
            SELECT Id, Player__c, Question__c, Answer__c, Timestamp__c, Score__c
            FROM Quiz_Answer__c
            WHERE
                Question__c = :question.Id
                AND Answer__c = :question.Correct_Answer__c
            WITH SECURITY_ENFORCED
            ORDER BY Timestamp__c ASC
        ];
    }

    public Quiz_Answer__c getFromPlayer(Id playerId, Id questionId) {
        return (Quiz_Answer__c) getSingleRecord(
            'Quiz_Answer__c',
            [
                SELECT Id, Player__c, Question__c, Answer__c, Score__c
                FROM Quiz_Answer__c
                WHERE Player__c = :playerId AND Question__c = :questionId
                WITH SECURITY_ENFORCED
            ]
        );
    }

    public class InvalidPhaseException extends Exception {
    }
    public class DuplicateAnswerException extends Exception {
    }

    public class PlayerStats {
        @AuraEnabled
        public Integer wrongCount;
        @AuraEnabled
        public Integer correctCount;
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public Decimal score;
        @AuraEnabled
        public Integer rank;
        @AuraEnabled
        public String name;

        public PlayerStats(
            Integer wrongCount,
            Integer correctCount,
            Integer totalCount,
            Decimal score,
            Integer rank,
            String name
        ) {
            this.wrongCount = wrongCount;
            this.correctCount = correctCount;
            this.totalCount = totalCount;
            this.score = score;
            this.rank = rank;
            this.name = name;
        }
    }
}
