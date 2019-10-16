import { LightningElement, track } from 'lwc';

export default class CountDownTimer extends LightningElement {
    // TODO: pass in number of seconds
    @track numberOfSeconds = 6;
    timerId;

    connectedCallback() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timerId = setInterval(() => {
            this.countDown();
        }, 1000);
    }

    disconnectedCallback() {
        clearInterval(this.timerId);
    }

    countDown() {
        this.numberOfSeconds--;
        if (this.numberOfSeconds === 0) {
            this.dispatchEvent(new CustomEvent('timeout'));
            clearInterval(this.timerId);
        }
    }
}
