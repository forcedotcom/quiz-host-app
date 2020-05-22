@isTest
public class QuizSessionTestFactory {
    public static final String PLAYER_NAME_PREFIX = 'player';
    private static final String PHASE_REGISTRATION = QuizSessionService.Phase.Registration.name();

    public static Quiz_Session__c createQuizSession() {
        // create one quiz session with all the relevant records
        Quiz_Question__c question = createQuizQuestion();
        Quiz_Session__c session = new Quiz_Session__c(
            Phase__c = PHASE_REGISTRATION,
            Current_Question__r = question,
            Current_Question__c = question.Id
        );
        insert session;
        createQuizSessionQuestion(session, question, 0);
        return session;
    }

    public static Quiz_Question__c createQuizQuestion() {
        Quiz_Question__c question = new Quiz_Question__c(
            Label__c = 'What does SLDS stand for?',
            Answer_A__c = 'Super Light Debugging Solution',
            Answer_B__c = 'Salesforce Lightning Design System',
            Answer_C__c = 'Salesforce Limited Design System',
            Answer_D__c = 'Salesforce Lightning Design Solution',
            Correct_Answer__c = 'B'
        );
        insert question;
        return question;
    }

    public static Quiz_Player__c createQuizPlayerWithScore(
        String name,
        Integer Score
    ) {
        Quiz_Player__c player = new Quiz_Player__c(
            Name = name,
            Score__c = score
        );
        insert player;
        return player;
    }

    public static List<Quiz_Player__c> createQuizPlayers(Integer playerCount) {
        List<Quiz_Player__c> players = new List<Quiz_Player__c>();
        for (Integer i = 0; i < playerCount; i++) {
            players.add(new Quiz_Player__c(Name = PLAYER_NAME_PREFIX + i));
        }
        insert players;
        return players;
    }

    public static Quiz_Answer__c createQuizAnswer(
        String playerId,
        String questionId,
        String answer
    ) {
        Quiz_Answer__c answerRecord = new Quiz_Answer__c(
            Player__c = playerId,
            Question__c = questionId,
            Answer__c = answer
        );
        insert answerRecord;
        return answerRecord;
    }

    public static Quiz_Session_Question__c createQuizSessionQuestion(
        Quiz_Session__c session,
        Quiz_Question__c question,
        Integer index
    ) {
        Quiz_Session_Question__c sessionQuestion = new Quiz_Session_Question__c(
            Session__r = session,
            Session__c = session.Id,
            Question_Index__c = index,
            Question__r = question,
            Question__c = question.Id
        );
        insert sessionQuestion;
        return sessionQuestion;
    }
}
