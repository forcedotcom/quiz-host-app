import { createElement } from 'lwc';
import QrCode from 'c/qrCode';

const IMAGE_BASE_URL = 'https://localhost/hello';
const IMAGE_SIZE = 300;

describe('qr-code', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays the right image', () => {
        const element = createElement('c-qr-code', {
            is: QrCode
        });
        element.url = IMAGE_BASE_URL;
        element.size = IMAGE_SIZE;
        document.body.appendChild(element);

        const img = element.shadowRoot.querySelector('img');
        expect(img.src).toBe(
            `https://chart.googleapis.com/chart?chs=${IMAGE_SIZE}x${IMAGE_SIZE}&cht=qr&chl=${encodeURIComponent(
                IMAGE_BASE_URL
            )}`
        );
    });
});
