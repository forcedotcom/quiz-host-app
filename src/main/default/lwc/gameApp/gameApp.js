import { LightningElement, track, wire } from 'lwc';
import getQuestionList from '@salesforce/apex/QuizComponentService.getQuestionList';
import getQuizSession from '@salesforce/apex/QuizComponentService.getQuizSession';
import { updateRecord } from 'lightning/uiRecordApi';

import { reduceErrors } from 'c/errorUtils';
// - Registration,
// for each question:
//    - PreQuestion, Question, PostQuestion
// - QuestionResults
// - GameResults
export default class GameApp extends LightningElement {
    @wire(getQuestionList) questions;
    @track error;
    @track quizSession;
    @track gameSessionPhase = 'Registration';
    questionIndex = 0;
    questionPhases = [
        'PreQuestion',
        'Question',
        'PostQuestion',
        'QuestionResults'
    ];
    phases = ['Registration', ...this.questionPhases, 'GameResults'];    
    
    @wire(getQuizSession)
    wiredQuizSession({ error, data }) {
        if (data) {
            this.quizSession = data;
            this.gameSessionPhase = data.Phase__c;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }        

    get nextButtonText() {
        if (this.isRegistration) return 'Start!';
        if (this.isPreQuestion) return 'Ready!';
        if (this.isGameResults) return 'Re-Start';
        return 'Next';
    }
    get currentQuestion() {
        return this.questions.data
            ? this.questions.data[this.questionIndex]
            : undefined;
    }
    get isQuestionPhase() {
        // use to show the <Question />. Exclude the pre question phase
        return (
            this.gameSessionPhase !== 'PreQuestion' &&
            this.questionPhases.includes(this.gameSessionPhase)
        );
    }
    get isRegistration() {
        return this.gameSessionPhase === 'Registration';
    }

    get isPreQuestion() {
        return this.gameSessionPhase === 'PreQuestion';
    }

    get isQuestion() {
        return this.gameSessionPhase === 'Question';
    }

    get isPostQuestion() {
        return this.gameSessionPhase === 'PostQuestion';
    }

    get isQuestionResults() {
        return this.gameSessionPhase === 'QuestionResults';
    }

    get isGameResults() {
        return this.gameSessionPhase === 'GameResults';
    }

    updatePhase() {
        const record = {
            fields: {
                Id: this.quizSession.Id,
                Phase__c: this.gameSessionPhase,
                Current_Question__c: this.questions.data[this.questionIndex].Id
            }
        };
        updateRecord(record)
            .then(() => {
                this.error = undefined;
            })
            .catch(error => {
                this.error = reduceErrors(error);
            });
    }

    handleNextPhaseClick() {
        if (this.gameSessionPhase === 'GameResults') {
            this.questionIndex = 0;
            this.gameSessionPhase = 'Registration';
            this.updatePhase();
            return;
        }
        // if it is a question phase, go to the next phase OR next question
        if (this.questionPhases.includes(this.gameSessionPhase)) {
            // go to PreQuestion or GameResults
            if (this.gameSessionPhase === 'QuestionResults') {
                if (this.questionIndex === this.questions.data.length - 1) {
                    this.gameSessionPhase = 'GameResults';
                    this.updatePhase();
                    return;
                }
                // Go to PreQuestion
                this.questionIndex += 1;
                this.gameSessionPhase = 'PreQuestion';
                this.updatePhase();
                return;
            }
            // loop through question Phases
            this.gameSessionPhase = this.questionPhases[
                (this.questionPhases.indexOf(this.gameSessionPhase) + 1) %
                    this.questionPhases.length
            ];
        } else {
            this.gameSessionPhase = this.phases[
                this.phases.indexOf(this.gameSessionPhase) + 1
            ];
        }

        this.updatePhase();
    }
}
