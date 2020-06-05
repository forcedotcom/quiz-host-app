import { LightningElement, api } from 'lwc';

export default class Registration extends LightningElement {
    @api quizSettings;

    get shortMobileAppUrl() {
        if (this.quizSettings) {
            return this.quizSettings.playerAppUrlMinified.replace(
                'https://',
                ''
            );
        }
        return '';
    }
}
