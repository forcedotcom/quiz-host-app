import { LightningElement, track } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import { reduceErrors } from 'c/errorUtils';

export default class LeaderBoard extends LightningElement {
    @track error;
    @track players;

    connectedCallback() {
        getPlayersSortedByScore({ maxFetchCount: 10 })
            .then(players => {
                this.error = undefined;
                this.displayPlayers(players);
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.players = undefined;
            });
    }

    displayPlayers(players) {
        this.players = [];
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        const intervalId = setInterval(() => {
            if (players.length > 0) {
                const player = players.shift();
                this.players.push(player);
            } else {
                clearInterval(intervalId);
            }
        }, 100);
    }
}
