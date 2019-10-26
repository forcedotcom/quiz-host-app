import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chart'; 

export default class LibsChartjs extends LightningElement {
    @track error;
    chart;
    chartjsInitialized = false;

    config = {
        type: 'bar',
        data: {
          labels: ["A", "B", "C", "D"],
          datasets: [{
            label: '# of Answers per Type',
            data: [12, 19, 3, 5],
            backgroundColor: [
              '#1589ee',
              '#ff9e2c',
              '#d4504c',
              '#04844b'
            ]
          }]
        },
        options: {
          responsive: true,
          scales: {
            xAxes: [{
              ticks: {
                maxRotation: 90,
                minRotation: 80
              }
            }],
            yAxes: [{
              ticks: {
                beginAtZero: true
              }
            }]
          }
        }
    };

    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        loadScript(this, chartjs)
            .then(() => {
                const canvas = document.createElement('canvas');
                this.template.querySelector('div.chart').appendChild(canvas);
                const ctx = canvas.getContext('2d');
                this.chart = new window.Chart(ctx, this.config);
            })
            .catch(error => {
                this.error = error;
            });
    }
}
