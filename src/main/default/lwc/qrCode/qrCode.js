import { LightningElement, api } from 'lwc';

export default class QrCode extends LightningElement {
    @api size = 150;
    @api url;

    get imageUrl() {
        if (!this.url) {
            return null;
        }
        return `https://api.qrserver.com/v1/create-qr-code/?size=${this.size}x${
            this.size
        }&data=${encodeURIComponent(this.url)}`;
    }
}
