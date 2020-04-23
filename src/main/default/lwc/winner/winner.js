import { LightningElement, track } from 'lwc';
import getWinnerStats from '@salesforce/apex/QuizController.getWinnerStats';
import { reduceErrors } from 'c/errorUtils';

export default class Winner extends LightningElement {
    @track winnerStats;
    @track error;

    connectedCallback() {
        getWinnerStats()
            .then((result) => {
                this.winnerStats = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.winnerStats = undefined;
            });
    }
}
