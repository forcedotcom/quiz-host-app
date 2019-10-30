import { LightningElement, track, wire } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @track winnerPlayer;
    @wire(getPlayersSortedByScore, { maxFetchCount: 1 })
    wiredPlayer({ error, data }) {
        if (data) {
            this.winnerPlayer = data.length ? data[0] : undefined;
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
