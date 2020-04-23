import { LightningElement, track, api } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import saveLeaderboard from '@salesforce/apex/QuizController.saveLeaderboard';
import { reduceErrors } from 'c/errorUtils';

export default class LeaderBoard extends LightningElement {
    @track error;
    @track players;
    @api isResultPhase;

    connectedCallback() {
        getPlayersSortedByScore({ maxFetchCount: 10 })
            .then((players) => {
                this.error = undefined;
                this.displayPlayers(players);
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.players = undefined;
            });

        if (this.isResultPhase) {
            saveLeaderboard()
                .then((result) => {
                    console.log('Saved to leaderboard successfully!');
                    console.log(result);
                })
                .catch((error) => {
                    this.error = reduceErrors(error);
                });
        }
    }

    displayPlayers(players) {
        const playersToDisplay = JSON.parse(JSON.stringify(players));
        this.players = [];
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        const intervalId = setInterval(() => {
            if (playersToDisplay.length > 0) {
                const player = playersToDisplay.shift();
                this.players.push(player);
            } else {
                clearInterval(intervalId);
            }
        }, 100);
    }
}
