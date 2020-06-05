global with sharing class QuizPlayer {
    @AuraEnabled
    global Id id { get; set; }
    @AuraEnabled
    global String name { get; set; }
    @AuraEnabled
    global Decimal score { get; set; }
    @AuraEnabled
    global Decimal rank { get; set; }

    global QuizPlayer() {
    }

    global QuizPlayer(Quiz_Player__c player) {
        this.id = player.Id;
        this.name = player.Name;
        this.score = player.Score__c;
        this.rank = player.Ranking__c;
    }

    global static List<QuizPlayer> fromRecordList(
        List<Quiz_Player__c> records
    ) {
        List<QuizPlayer> players = new List<QuizPlayer>();
        for (Quiz_Player__c record : records) {
            players.add(new QuizPlayer(record));
        }
        return players;
    }
}
