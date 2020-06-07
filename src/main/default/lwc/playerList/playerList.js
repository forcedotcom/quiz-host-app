import { LightningElement, track } from 'lwc';
import getPlayersSortedByScore from '@salesforce/apex/QuizController.getPlayersSortedByScore';
import { reduceErrors } from 'c/errorUtils';
import * as empApi from 'lightning/empApi';
import PLAYER_OBJECT from '@salesforce/schema/Quiz_Player__c';

export default class PlayerList extends LightningElement {
    error;
    @track playerNames = [];

    subscription;

    connectedCallback() {
        getPlayersSortedByScore()
            .then((players) => {
                this.playerNames = players.map((player) => player.name);
                this.error = undefined;
                this.initEmpApi();
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.playerNames = undefined;
            });
    }

    initEmpApi() {
        const ns = PlayerList.getNamespacePrefix(PLAYER_OBJECT.objectApiName);
        empApi.onError((error) => {
            // eslint-disable-next-line no-console
            console.error('Streaming API error: ' + JSON.stringify(error));
        });
        empApi
            .subscribe(
                `/data/${ns}Quiz_Player__ChangeEvent`,
                -1,
                (cdcEvent) => {
                    if (
                        cdcEvent.data.payload.ChangeEventHeader.changeType ===
                        'CREATE'
                    ) {
                        this.handlePlayerCreationEvent(cdcEvent);
                    }
                }
            )
            .then((response) => {
                this.subscription = response;
            });
    }

    static getNamespacePrefix(objectApiName) {
        if (objectApiName.match(/__/g).length === 2) {
            return objectApiName.split('__')[0] + '__';
        }
        return '';
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
