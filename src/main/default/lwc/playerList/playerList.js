import { LightningElement, track } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import { reduceErrors } from 'c/errorUtils';
import * as empApi from 'lightning/empApi';

export default class playerList extends LightningElement {
    @track error;
    @track playerNames;

    subscription;

    connectedCallback() {
        getPlayersSortedByScore()
            .then(players => {
                this.playerNames = players.map(player => player.Name);
                this.error = undefined;
                this.initEmpApi();
            })
            .catch(error => {
                this.error = reduceErrors(error);
                this.playerNames = undefined;
            });
    }

    initEmpApi() {
        empApi.onError(error => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe('/data/Quiz_Player__ChangeEvent', -1, cdcEvent => {
                if (
                    cdcEvent.data.payload.ChangeEventHeader.changeType ===
                    'CREATE'
                ) {
                    this.handlePlayerCreationEvent(cdcEvent);
                }
            })
            .then(response => {
                this.subscription = response;
            });
    }

    handlePlayerCreationEvent(cdcEvent) {
        const { Name } = cdcEvent.data.payload;
        if (!this.playerNames.includes(Name)) {
            this.playerNames.push(Name);
        }
    }

    disconnectedCallback() {
        if (this.subscription) {
            empApi.unsubscribe(this.subscription, () => {
                this.subscription = undefined;
            });
        }
    }

    get playerCount() {
        return this.playerNames ? `(${this.playerNames.length})` : '';
    }
}
