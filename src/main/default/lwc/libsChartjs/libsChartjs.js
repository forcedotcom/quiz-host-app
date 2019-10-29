import { LightningElement, api, track, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chart';
import chartJsPlugin from '@salesforce/resourceUrl/chartJsPlugin';
import getAnswerMap from '@salesforce/apex/QuizController.getAnswerMap';
import { reduceErrors } from 'c/errorUtils';

export default class LibsChartjs extends LightningElement {
    @api questionId;
    @api correctAnswer; // A, B, C, or D
    @track error;
    @track answerCount;
    chart;
    chartjsInitialized = false;
    labels = ['A', 'B', 'C', 'D'];
    showNoAnswerMessage = true;

    @wire(getAnswerMap, { sessionId: '$questionId' })
    wiredQuizSettings({ error, data }) {
        if (data) {
            // no answers found
            if (JSON.stringify(data) === '{}') {
                this.showNoAnswerMessage = true;
                this.error = undefined;
                return;
            }
            
            // turn object {"A":1,"B":1,"D":2} into array [1, 1, 0, 2]
            const arr = [];
            this.labels.forEach(letter => {
                if (data.hasOwnProperty(letter)) arr.push(data[letter]);
                else arr.push(0);
            });
            this.answerCount = arr;
            this.error = undefined;
            this.renderGraph();
        } else if (error) {
            this.error = reduceErrors(error);
            this.answerCount = undefined;
        }
    }

    renderGraph() {
        loadScript(this, chartjs)
            .then(() => loadScript(this, chartJsPlugin))
            .then(() => {
                this.showNoAnswerMessage = false;
                const canvas = document.createElement('canvas');
                this.template.querySelector('.chart').appendChild(canvas);
                const ctx = canvas.getContext('2d');
                window.Chart.defaults.global.defaultFontSize = 24;
                const config = {
                    type: 'bar',
                    data: {
                        labels: this.labels,
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
                                        display:false
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
        if (this.answerCount == null) {
            this.showNoAnswerMessage = true;
            return;
        }
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;
        this.renderGraph();
    }
}
