import { LightningElement, track } from 'lwc'

export default class CountDownTimer extends LightningElement {
    // TODO: pass in number of seconds
    @track numberOfSeconds = 6;
    connectedCallback() {
        this.countDown();
    }
    countDown() {
        this.numberOfSeconds -= 1;
        this.numberOfSeconds =
            this.numberOfSeconds > 0 ? this.numberOfSeconds : 0;
            console.log(this.numberOfSeconds)
        const self = this;
        window.setTimeout(function() {
            self.countDown();
        }, 1000)
    }
}
