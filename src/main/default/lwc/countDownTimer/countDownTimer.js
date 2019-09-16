import { LightningElement, track } from 'lwc'

export default class CountDownTimer extends LightningElement {
    // TODO: pass in number of seconds
    @track numberOfSeconds = 6;
    timerID;
    
    connectedCallback() {
        this.timerID = setInterval(() => {
            this.countDown();
          }, 1000);   
    }

    countDown() { 
        this.numberOfSeconds =
            this.numberOfSeconds > 0 ? this.numberOfSeconds -= 1 : 0;
        if (this.numberOfSeconds === 0) {
            this.dispatchEvent(new CustomEvent('timeout'));
            clearTimeout(this.timerID);
        }
    }
}
