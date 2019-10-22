import { LightningElement, track, wire } from 'lwc';
import { reduceErrors } from 'c/errorUtils';
import getMobileAppUrl from '@salesforce/apex/QuizController.getMobileAppUrl';

export default class QrCode extends LightningElement {
    @track error;
    @track url;
    @track src;
    qrCodeInitialized = false;

    @wire(getMobileAppUrl)
    wiredPlayers(result) {
        const { error, data } = result;
        if (data) {
            this.url = data;
            this.error = undefined;
        } else if (error) {
            this.error = reduceErrors(error);
            this.url = undefined;
        }
    }

    renderedCallback() {
        if (this.qrCodeInitialized || !this.url) {
            return;
        }
        this.qrCodeInitialized = true;
        const imageUrl =
            'https://chart.googleapis.com/chart?chs=150x150&cht=qr&chl=' +
            encodeURIComponent(this.url);

        fetch(imageUrl)
            .then(() => {
                this.src = imageUrl;
            })
            .catch(error => {
                this.error =
                    'Error from QR code render: ' +
                    reduceErrors(error).join('.');
            });
    }
}
