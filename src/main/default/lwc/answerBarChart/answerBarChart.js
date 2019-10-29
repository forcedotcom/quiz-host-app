import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chart';
import chartjsPluginDatalabels from '@salesforce/resourceUrl/chartjsPluginDatalabels';

export default class LibsChartjs extends LightningElement {
    @api answerCount;
    @api correctAnswer; // A, B, C, or D
    @track error;
    chart;
    chartjsInitialized = false;
    @api labels;

    renderGraph() {
        loadScript(this, chartjs)
            .then(() => loadScript(this, chartjsPluginDatalabels))
            .then(() => {
                const canvas = document.createElement('canvas');
                this.template.querySelector('.chart').appendChild(canvas);
                const ctx = canvas.getContext('2d');
                window.Chart.defaults.global.defaultFontSize = 24;
                const config = {
                    type: 'bar',
                    data: {
                        labels: JSON.parse(JSON.stringify(this.labels)),
                        datasets: [
                            {
                                label: '# of Answers per Type',
                                data: JSON.parse(
                                    JSON.stringify(this.answerCount)
                                ),
                                backgroundColor: [
                                    '#1589ee',
                                    '#ff9e2c',
                                    '#d4504c',
                                    '#04844b'
                                ]
                            }
                        ]
                    },
                    options: {
                        tooltips: {
                            enabled: false
                        },
                        legend: {
                            display: false
                        },
                        plugins: {
                            datalabels: {
                                anchor: 'end',
                                align: 'top',
                                color: 'black',
                                textAlign: 'center',
                                formatter: (value, context) => {
                                    const label =
                                        context.chart.data.labels[
                                            context.dataIndex
                                        ];
                                    return label === this.correctAnswer
                                        ? `✔ ${value}`
                                        : value;
                                }
                            }
                        },
                        responsive: true,
                        layout: {
                            padding: {
                                top: 50
                            }
                        },
                        scales: {
                            xAxes: [
                                {
                                    gridLines: {
                                        display: false
                                    }
                                }
                            ],
                            yAxes: [
                                {
                                    display: false
                                }
                            ]
                        }
                    }
                };
                this.chart = new window.Chart(ctx, config);
            })
            .catch(error => {
                this.error = error;
            });
    }

    renderedCallback() {
        if (this.chartjsInitialized || this.showNoAnswerMessage) {
            return;
        }
        this.chartjsInitialized = true;
        this.renderGraph();
    }

    get showNoAnswerMessage() {
        return this.answerCount === undefined;
    }
}
