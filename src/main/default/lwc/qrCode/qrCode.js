import { LightningElement, api } from 'lwc';

export default class QrCode extends LightningElement {
    @api size = 150;
    @api url;

    get imageUrl() {
        if (!this.url) {
            return null;
        }
        return `https://chart.googleapis.com/chart?chs=${this.size}x${
            this.size
        }&cht=qr&chl=${encodeURIComponent(this.url)}`;
    }
}
