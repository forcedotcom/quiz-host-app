public with sharing class PlayerStat {
    @AuraEnabled
    public Integer wrongCount;
    @AuraEnabled
    public Integer correctCount;
    @AuraEnabled
    public Integer totalCount;
    @AuraEnabled
    public Decimal score;
    @AuraEnabled
    public String name;

    public PlayerStat(
        Integer wrongCount,
        Integer correctCount,
        Integer totalCount,
        Decimal score,
        String name
    ) {
        this.wrongCount = wrongCount;
        this.correctCount = correctCount;
        this.totalCount = totalCount;
        this.score = score;
        this.name = name;
    }
}
