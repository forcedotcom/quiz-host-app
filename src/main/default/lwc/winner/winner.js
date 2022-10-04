import { LightningElement, wire, api } from 'lwc';
import getWinnerStats from '@salesforce/apex/QuizController.getWinnerStats';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @api sessionId;
    winnerStats;
    error;

    @wire(getWinnerStats, { sessionId: '$sessionId' })
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
