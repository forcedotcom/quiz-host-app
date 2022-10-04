import { LightningElement } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import getCurrentQuestion from '@salesforce/apex/QuizController.getCurrentQuestion';
import resetGame from '@salesforce/apex/QuizController.resetGame';
import getAndCheckSettings from '@salesforce/apex/QuizController.getAndCheckSettings';
import getQuizSession from '@salesforce/apex/QuizController.getQuizSession';
import triggerNextPhase from '@salesforce/apex/QuizController.triggerNextPhase';
import { reduceErrors } from 'c/errorUtils';

const PHASES = {
    Registration: { label: 'Registration', nextButtonLabel: 'Start!' },
    PreQuestion: { label: 'Get Ready!', nextButtonLabel: 'Ready!' },
    Question: { label: 'Question', nextButtonLabel: 'Next' },
    QuestionResults: { label: 'Answer', nextButtonLabel: 'Next' },
    GameResults: { label: 'Game Over', nextButtonLabel: 'New Game' }
};

export default class GameApp extends LightningElement {
    error;
    isNextButtonDisabled = true;
    quizSession;
    quizSettings;
    currentQuestion;

    HOST_APP_VERSION = '4.0.0';

    connectedCallback() {
        this.loadQuiz();
    }

    async loadQuiz() {
        try {
            // Reset vars
            this.error = undefined;
            this.isNextButtonDisabled = true;
            this.quizSession = undefined;
            this.quizSettings = undefined;
            this.currentQuestion = undefined;
            // Load data
            [this.quizSettings, this.quizSession] = await Promise.all([
                getAndCheckSettings(),
                getQuizSession()
            ]);
            await this.refreshCurrentQuestion();
        } catch (error) {
            this.error = reduceErrors(error);
            this.isNextButtonDisabled = true;
        }
    }

    async refreshCurrentQuestion() {
        try {
            this.currentQuestion = await getCurrentQuestion({
                sessionId: this.quizSession.id
            });
            // Double phase change click prevention
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                if (!this.error) {
                    this.isNextButtonDisabled = false;
                }
            }, 2000);
        } catch (error) {
            this.error = reduceErrors(error);
            this.currentQuestion = undefined;
            this.isNextButtonDisabled = true;
        }
    }

    async handleNextPhaseClick() {
        // Request confirmation for new game
        if (this.quizSession.phase === 'GameResults') {
            const isConfirmed = await LightningConfirm.open({
                label: 'Start new game',
                message:
                    "Starting a new game will clear the current game's data. Do you wish to proceed?",
                theme: 'warning'
            });
            if (!isConfirmed) {
                return;
            }
        }

        this.isNextButtonDisabled = true;
        this.answerCount = undefined;
        try {
            this.quizSession = await triggerNextPhase({
                sessionId: this.quizSession.id
            });
            this.error = undefined;
            this.refreshCurrentQuestion();
        } catch (error) {
            this.error = reduceErrors(error);
            this.quizSession = undefined;
        }
    }

    async handleResetClick() {
        const isConfirmed = await LightningConfirm.open({
            label: 'Reset game',
            message: 'Delete game data (players and answers)?',
            theme: 'warning'
        });
        if (isConfirmed) {
            try {
                this.template.querySelector('.player-list').reset();
                await resetGame({ sessionId: this.quizSession.id });
                await this.loadQuiz();
            } catch (error) {
                this.error = reduceErrors(error);
                this.quizSession = undefined;
            }
        }
    }

    get quizPhaseLabel() {
        if (this.quizSession) {
            return PHASES[this.quizSession.phase].label;
        }
        return 'Loading...';
    }

    get nextButtonText() {
        if (this.quizSession) {
            return PHASES[this.quizSession.phase].nextButtonLabel;
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

    get isDoneLoading() {
        return (
            this.quizSession !== undefined &&
            this.quizSettings !== undefined &&
            this.currentQuestion !== undefined
        );
    }
}
