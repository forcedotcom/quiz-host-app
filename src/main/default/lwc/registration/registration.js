import { LightningElement, api } from 'lwc';

const QR_CODE_SIZE = 400;

export default class Registration extends LightningElement {
    @api sessionId;
    @api quizSettings;

    get sessionUrl() {
        return `${this.quizSettings.playerAppUrl}/?sessionId=${this.sessionId}`;
    }

    get qrCodeImageUrl() {
        if (this.quizSettings && this.sessionId) {
            return `https://chart.googleapis.com/chart?chs=${QR_CODE_SIZE}x${QR_CODE_SIZE}&cht=qr&chl=${encodeURIComponent(
                this.sessionUrl
            )}`;
        }
        return undefined;
    }
}
