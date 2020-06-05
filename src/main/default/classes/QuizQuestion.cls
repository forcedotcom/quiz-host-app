global with sharing class QuizQuestion {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String label { get; set; }
    @AuraEnabled
    global String answerA { get; set; }
    @AuraEnabled
    global String answerB { get; set; }
    @AuraEnabled
    global String answerC { get; set; }
    @AuraEnabled
    global String answerD { get; set; }
    @AuraEnabled
    global String correctAnswer { get; set; }

    global QuizQuestion() {
    }

    global QuizQuestion(Quiz_Question__c question) {
        this.id = question.Id;
        this.label = question.Label__c;
        // Retrieve optional fields
        try {
            this.answerA = question.Answer_A__c;
            this.answerB = question.Answer_B__c;
            this.answerC = question.Answer_C__c;
            this.answerD = question.Answer_D__c;
            this.correctAnswer = question.Correct_Answer__c;
        } catch (Exception e) {
            // Do nothing if fields are not available
        }
    }

    global static List<QuizQuestion> fromRecordList(
        List<Quiz_Question__c> records
    ) {
        List<QuizQuestion> questions = new List<QuizQuestion>();
        for (Quiz_Question__c record : records) {
            questions.add(new QuizQuestion(record));
        }
        return questions;
    }
}
