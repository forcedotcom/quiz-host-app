import { LightningElement, wire } from 'lwc';
import getCurrentQuestion from '@salesforce/apex/QuizController.getCurrentQuestion';
import resetGame from '@salesforce/apex/QuizController.resetGame';
import checkSettings from '@salesforce/apex/QuizController.checkSettings';
import getQuizSession from '@salesforce/apex/QuizController.getQuizSession';
import getQuizSettings from '@salesforce/apex/QuizController.getQuizSettings';
import triggerNextPhase from '@salesforce/apex/QuizController.triggerNextPhase';
import { reduceErrors } from 'c/errorUtils';

export default class GameApp extends LightningElement {
    error;
    quizSession;
    quizSettings;
    isNextButtonDisabled = true;
    currentQuestion;

    HOST_APP_VERSION = '2.9.0';

    @wire(getQuizSettings)
    wiredQuizSettings({ error, data }) {
        if (data) {
            this.quizSettings = data;
        } else if (error) {
            this.error = reduceErrors(error);
            this.quizSettings = undefined;
        }
    }

    connectedCallback() {
        checkSettings().catch((error) => {
            this.error = reduceErrors(error);
            this.isNextButtonDisabled = true;
        });
        getQuizSession()
            .then((quizSession) => {
                this.quizSession = quizSession;
                this.refreshCurrentQuestion();
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.quizSession = undefined;
            });
    }

    refreshCurrentQuestion() {
        getCurrentQuestion({ sessionId: this.quizSession.id })
            .then((currentQuestion) => {
                this.currentQuestion = currentQuestion;
                // Double phase change click prevention
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    if (!this.error) {
                        this.isNextButtonDisabled = false;
                    }
                }, 2000);
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.currentQuestion = undefined;
                this.isNextButtonDisabled = true;
            });
    }

    handleNextPhaseClick() {
        this.isNextButtonDisabled = true;
        this.answerCount = undefined;
        triggerNextPhase({ sessionId: this.quizSession.id })
            .then((updatedSession) => {
                this.quizSession = updatedSession;
                this.error = undefined;
                this.refreshCurrentQuestion();
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.quizSession = undefined;
            });
    }

    handleResetClick() {
        // eslint-disable-next-line no-alert
        if (window.confirm('Delete game data (players and answers)?')) {
            resetGame().then(() => {
                window.location.reload();
            });
        }
    }

    get quizPhaseLabel() {
        if (this.quizSession) {
            if (this.isRegistrationPhase) return 'Registration';
            if (this.isPreQuestionPhase) return 'Get Ready!';
            if (this.isQuestionPhase) return 'Question';
            if (this.isQuestionResultsPhase) return 'Answer';
            if (this.isGameResultsPhase) return 'Game Over';
        }
        return 'Loading...';
    }

    get nextButtonText() {
        if (this.quizSession) {
            if (this.isRegistrationPhase) return 'Start!';
            if (this.isPreQuestionPhase) return 'Ready!';
            if (this.isGameResultsPhase) return 'New Game';
            return 'Next';
        }
        return 'Loading...';
    }

    get correctAnswerLabel() {
        const { currentQuestion } = this;
        const correctAnswer = currentQuestion.correctAnswer;
        const answerLabel = this.currentQuestion[`answer${correctAnswer}`];
        return `${correctAnswer}: ${answerLabel}`;
    }

    get cardBodyClasses() {
        let bgColorClass = this.quizSession
            ? `bg-${this.quizSession.phase}`
            : '';
        return `slds-card__body slds-card__body_inner ${bgColorClass}`;
    }

    get isRegistrationPhase() {
        return this.quizSession.phase === 'Registration';
    }

    get isPreQuestionPhase() {
        return this.quizSession.phase === 'PreQuestion';
    }

    get isQuestionPhase() {
        return this.quizSession.phase === 'Question';
    }

    get isQuestionResultsPhase() {
        return this.quizSession.phase === 'QuestionResults';
    }

    get isGameResultsPhase() {
        return this.quizSession.phase === 'GameResults';
    }
}
