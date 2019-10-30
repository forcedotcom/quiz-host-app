import { LightningElement, track, wire } from 'lwc';
import getWinnerStats from '@salesforce/apex/QuizController.getWinnerStats';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @track winnerStats;
    @track error;

    @wire(getWinnerStats)
    wiredPlayer({ error, data }) {
        if (data) {
            this.winnerStats = data;
            this.error = undefined;
        } else if (error) {
            this.error = reduceErrors(error);
            this.winnerStats = undefined;
        }
    }
}
