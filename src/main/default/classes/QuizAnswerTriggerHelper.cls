public with sharing class QuizAnswerTriggerHelper {
    public static void beforeInsert(List<Quiz_Answer__c> newAnswers) {
        QuizAnswerService answerService = new QuizAnswerService();
        Set<Id> playerIds = answerService.getUniquePlayerIds(newAnswers);
        Map<Id, Id> mapPlayerQuestion = answerService.getPlayerQuestionMapping(
            playerIds
        );
        for (Quiz_Answer__c answer : newAnswers) {
            String key = answer.Player__c;
            if (
                mapPlayerQuestion.containsKey(key) &&
                mapPlayerQuestion.get(key) == answer.Question__c
            ) {
                answer.addError('Duplicate answer');
            } else {
                // # of milliseconds since January 1, 1970, 00:00:00 GMT, ie. 1569261277045
                answer.Timestamp__c = Datetime.now().getTime();
            }
        }
    }
}
