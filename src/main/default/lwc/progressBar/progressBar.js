import { LightningElement, api } from 'lwc';

const TIMER_INTERVAL_MS = 20;

export default class ProgressBar extends LightningElement {
    @api duration = 6;
    progress = 0;
    progressBarStyle = '';
    timerId;

    connectedCallback() {
        const durationMs = this.duration * 1000;
        let elapsedMs = 0;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timerId = setInterval(() => {
            elapsedMs += TIMER_INTERVAL_MS;
            const progressPercent = elapsedMs / durationMs;
            this.progress = Math.floor(100 * progressPercent);
            const color = this.getColor(progressPercent);
            this.progressBarStyle = `width: ${this.progress}%; background-color: ${color};`;
            if (this.progress >= 100) {
                this.progress = 100;
                clearInterval(this.timerId);
                this.dispatchEvent(new CustomEvent('timeout'));
            }
        }, TIMER_INTERVAL_MS);
    }

    getColor(percent) {
        const hue = ((1 - percent) * 120).toString(10);
        return `hsl(${hue}, 100%, 50%)`;
    }

    disconnectedCallback() {
        clearInterval(this.timerId);
    }
}
