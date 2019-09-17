import { LightningElement } from 'lwc';

export default class LeaderBoard extends LightningElement {
    players = [
        { name: 'Jerry Wood', score: 315 },
        { name: 'Brandon Barnes', score: 301 },
        { name: 'Raymond Knight', score: 292 },
        { name: 'Trevor McCormick', score: 245 },
        { name: 'Andrew Fox', score: 203 }
    ];
}
