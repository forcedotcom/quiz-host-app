import { LightningElement, track, wire } from 'lwc';
import getPlayerAnswerStats from '@salesforce/apex/QuizController.getPlayerAnswerStats';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @track winnerPlayer;
    @wire(getPlayerAnswerStats)
    wiredPlayer({ error, data }) {
        if (data) {
            // no winner found
            if (Object.entries(data).length === 0) {
                this.winnerPlayer = undefined;
            } else this.winnerPlayer = data;

            this.error = undefined;
        } else if (error) {
            this.error = reduceErrors(error);
            this.winnerPlayer = undefined;
        }
    }

    get noWinner() {
        return this.winnerPlayer === undefined;
    } 
}
