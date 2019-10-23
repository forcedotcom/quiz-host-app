import { LightningElement, api, track } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import { reduceErrors } from 'c/errorUtils';

export default class LeaderBoard extends LightningElement {
    @api showWinner;
    @api showLeaderboard;
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

    get winner() {
        return (this.players && this.players.length) > 0
            ? this.players[0]
            : undefined;
    }
}
