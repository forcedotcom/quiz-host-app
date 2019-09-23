import { LightningElement, track, wire } from 'lwc';
import getPlayerList from '@salesforce/apex/QuizController.getPlayerList';
import { reduceErrors } from 'c/errorUtils';

export default class LeaderBoard extends LightningElement {
    @track error;
    @track players;

    @wire(getPlayerList)
    getPlayerList({ error, data }) {
        if (data) {
            this.players = data;
        } else if (error) {
            this.error = reduceErrors(error);
            this.quizSession = undefined;
        }
    }    
}
