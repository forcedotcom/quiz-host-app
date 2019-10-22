import { LightningElement, track } from 'lwc';
import getCurrentQuestion from '@salesforce/apex/QuizController.getCurrentQuestion';
import getQuizSession from '@salesforce/apex/QuizController.getQuizSession';
import triggerNextPhase from '@salesforce/apex/QuizController.triggerNextPhase';

import { reduceErrors } from 'c/errorUtils';

export default class GameApp extends LightningElement {
    @track error;
    @track quizSession;
    @track isNextButtonDisabled = true;
    @track currentQuestion;

    connectedCallback() {
        getQuizSession()
            .then(quizSession => {
                this.quizSession = quizSession;
                this.error = undefined;
                this.refreshCurrentQuestion();
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.quizSession = undefined;
            });
    }

    refreshCurrentQuestion() {
        getCurrentQuestion({ sessionId: this.quizSession.Id })
            .then(currentQuestion => {
                this.currentQuestion = currentQuestion;
                this.error = undefined;
                this.isNextButtonDisabled = false;
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.currentQuestion = undefined;
                this.isNextButtonDisabled = true;
            });
    }

    handleNextPhaseClick() {
        triggerNextPhase({ sessionId: this.quizSession.Id })
            .then(updatedSession => {
                this.quizSession = updatedSession;
                this.error = undefined;
                this.refreshCurrentQuestion();
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.quizSession = undefined;
            });
    }

    get quizPhaseLabel() {
        if (this.quizSession) {
            if (this.isRegistrationPhase) return 'Registration';
            if (this.isPreQuestionPhase || this.isQuestionPhase)
                return 'Question';
            if (this.isQuestionResultsPhase) return 'Current Leaderboard';
            if (this.isGameResultsPhase) return 'Game Over';
        }
        return 'Loading...';
    }

    get nextButtonText() {
        if (this.isRegistrationPhase) return 'Start!';
        if (this.isPreQuestionPhase) return 'Ready!';
        if (this.isGameResultsPhase) return 'New Game';
        return 'Next';
    }

    get isRegistrationPhase() {
        return this.quizSession.Phase__c === 'Registration';
    }

    get isPreQuestionPhase() {
        return this.quizSession.Phase__c === 'PreQuestion';
    }

    get isQuestionPhase() {
        return this.quizSession.Phase__c === 'Question';
    }

    get isQuestionResultsPhase() {
        return this.quizSession.Phase__c === 'QuestionResults';
    }

    get isGameResultsPhase() {
        return this.quizSession.Phase__c === 'GameResults';
    }
}
