import { LightningElement, api, track, wire } from 'lwc';
import getPlayerList from '@salesforce/apex/QuizController.getPlayerList';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/errorUtils';

export default class LeaderBoard extends LightningElement {
    @api showWinner;
    @api showLeaderboard;
    @track error;
    @track players;
    wiredResult;

    @wire(getPlayerList)
    wiredPlayers(result) {
        this.wiredResult = result;
        const { error, data } = result;
        if (data) {
            this.players = data;
        } else if (error) {
            this.error = reduceErrors(error);
            this.quizSession = undefined;
        }
    }

    connectedCallback() {
        if (this.wiredResult) refreshApex(this.wiredResult);
    }    

    get winner() {
        return this.players ? this.players[0] : undefined;
    }    
}
