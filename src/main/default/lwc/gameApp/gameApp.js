import { LightningElement, track, wire } from 'lwc'
import getQuestionList from '@salesforce/apex/QuizComponentService.getQuestionList'
import updateQuestionSessionPhase from '@salesforce/apex/QuizComponentService.updateQuestionSessionPhase'
// - Registration,
// for each question:
//    - PreQuestion, Question, PostQuestion
// - QuestionResults
// - GameResults
export default class GameApp extends LightningElement {
    @wire(getQuestionList) questions;
    questionIndex = 0;
    // track status of update phase
    @track error;
    @track gameSessionPhase = 'Registration';
    questionPhases = [
        'PreQuestion',
        'Question',
        'PostQuestion',
        'QuestionResults',
    ];
    phases = ['Registration', ...this.questionPhases, 'GameResults'];

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
        )
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
        updateQuestionSessionPhase({ updatedPhase: this.gameSessionPhase })
            .then(result => {
                this.error = undefined;
            })
            .catch(error => {
                this.error = JSON.stringify(error);
            });
    }
    goToNextPhase() {
        // if it is a question phase, go to the next phase OR next question
        if (this.questionPhases.includes(this.gameSessionPhase)) {
            if (this.gameSessionPhase === 'QuestionResults') {
                if (this.questionIndex === this.questions.data.length - 1) {
                    this.gameSessionPhase = 'GameResults';
                    this.updatePhase();
                    return;
                } else {
                    this.questionIndex += 1;
                }
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
    restart() {
        this.questionIndex = 0;
        this.gameSessionPhase = 'Registration';
        this.updatePhase();
    }
}
