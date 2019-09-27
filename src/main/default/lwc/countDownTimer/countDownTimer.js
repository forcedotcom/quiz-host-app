import { LightningElement, track } from 'lwc';

export default class CountDownTimer extends LightningElement {
    // TODO: pass in number of seconds
    @track numberOfSeconds = 6;
    timerID;

    connectedCallback() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timerID = setInterval(() => {
            this.countDown();
        }, 1000);
    }

    disconnectedCallback() {
        clearInterval(this.timerID);
    }

    countDown() {
        this.numberOfSeconds--;
        if (this.numberOfSeconds === 0) {
            this.dispatchEvent(new CustomEvent('timeout'));
            clearInterval(this.timerID);
        }
    }
}
