import { LightningElement, track, wire } from 'lwc';
import getWinnerAnswerStats from '@salesforce/apex/QuizController.getWinnerAnswerStats';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @track winnerPlayer;
    @wire(getWinnerAnswerStats)
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

    get winnerName() {
        // name is the key of the first entry where value === -1
        return Object.entries(this.winnerPlayer).filter(
            pair => pair[1] === -1
        )[0][0];
    }
}
