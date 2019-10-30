import { LightningElement, track, wire } from 'lwc';
import getWinnerStats from '@salesforce/apex/QuizController.getWinnerStats';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @track winnerPlayer;
    @wire(getWinnerStats)
    wiredPlayer({ error, data }) {
        if (data) {
            this.winnerPlayer =
                Object.entries(data).length === 0
                    ? undefined
                    : (this.winnerPlayer = data);

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
