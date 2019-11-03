import { LightningElement, api } from 'lwc';

export default class Registration extends LightningElement {
    @api quizSettings;

    get shortMobileAppUrl() {
        if (this.quizSettings) {
            return this.quizSettings.Player_App_URL_Minified__c.replace(
                'https://',
                ''
            );
        }
        return '';
    }
}
