public with sharing class PlayerStat {
    Integer wrongCount;
    Integer correctCount;
    Decimal score;
    String name;

    public PlayerStat(Integer wrongCount, Integer correctCount, Decimal score, String name) {
        this.wrongCount = wrongCount;
        this.correctCount = correctCount;
        this.score = score;
        this.name = name;
    }
}
