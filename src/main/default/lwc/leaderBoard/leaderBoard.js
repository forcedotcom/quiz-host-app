import { LightningElement, track } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import { reduceErrors } from 'c/errorUtils';

export default class LeaderBoard extends LightningElement {
    @track error;
    @track players;

    connectedCallback() {
        getPlayersSortedByScore({ maxFetchCount: 10 })
            .then(players => {
                this.players = players;
                this.error = undefined;
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.players = undefined;
            });
    }
}
