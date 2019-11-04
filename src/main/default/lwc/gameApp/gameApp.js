import { LightningElement, track, wire } from 'lwc';
import getCurrentQuestion from '@salesforce/apex/QuizController.getCurrentQuestion';
import getQuizSession from '@salesforce/apex/QuizController.getQuizSession';
import getQuizSettings from '@salesforce/apex/QuizController.getQuizSettings';
import triggerNextPhase from '@salesforce/apex/QuizController.triggerNextPhase';
import getAnswerMap from '@salesforce/apex/QuizController.getAnswerMap';

import { reduceErrors } from 'c/errorUtils';
const arrColors = [
    'mediumpurple',
    'lightcoral',
    'lightsalmon',
    'mediumaquamarine',
    'mediumseagreen',
    'mediumturquoise',
    'darkgoldenrod'
];
function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}
export default class GameApp extends LightningElement {
    @track error;
    @track quizSession;
    @track quizSettings;
    @track isNextButtonDisabled = true;
    @track currentQuestion;
    @track answerCount;
    labels = ['A', 'B', 'C', 'D'];

    @wire(getQuizSettings)
    wiredQuizSettings({ error, data }) {
        if (data) {
            this.quizSettings = data;
            this.error = undefined;
        } else if (error) {
            this.error = reduceErrors(error);
            this.quizSettings = undefined;
        }
    }

    getAnswers() {
        getAnswerMap()
            .then(data => {
                // turn object {"A":1,"B":1,"D":2} into array [1, 1, 0, 2]
                const arr = [];
                this.labels.forEach(letter => {
                    if (data.hasOwnProperty(letter)) arr.push(data[letter]);
                    else arr.push(0);
                });
                this.answerCount = arr;
                this.error = undefined;
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.answerCount = undefined;
            });
    }

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
                if (this.isQuestionResultsPhase) {
                    this.getAnswers();
                }
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
                if (this.isQuestionResultsPhase) {
                    this.getAnswers();
                }
                // change background color
                const element = this.template.querySelector('.slds-card__body');
                const newColor = this.isRegistrationPhase
                    ? 'orange'
                    : arrColors[getRandomInt(arrColors.length)];
                element.style.setProperty('background', newColor);
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.quizSession = undefined;
            });
    }

    get quizPhaseLabel() {
        const { currentQuestion } = this;
        if (this.quizSession && currentQuestion) {
            if (this.isRegistrationPhase) return 'Registration';
            if (this.isPreQuestionPhase) return 'Get Ready!';
            if (this.isQuestionPhase) return currentQuestion.Label__c;
            if (this.isQuestionResultsPhase) {
                const answerLabel =
                    currentQuestion[
                        `Answer_${currentQuestion.Correct_Answer__c}__c`
                    ];
                return `Correct answer is ${currentQuestion.Correct_Answer__c}: ${answerLabel}`;
            }
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
