import PlayerList from 'c/playerList';

describe('player-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('getNamespacePrefix works with namespace', () => {
        const objectApiName = 'sfqz__Quiz_Player__c';
        const ns = PlayerList.getNamespacePrefix(objectApiName);
        expect(ns).toBe('sfqz__');
    });

    it('getNamespacePrefix works without namespace', () => {
        const objectApiName = 'Quiz_Player__c';
        const ns = PlayerList.getNamespacePrefix(objectApiName);
        expect(ns).toBe('');
    });
});
