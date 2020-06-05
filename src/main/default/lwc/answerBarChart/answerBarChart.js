import { LightningElement, api } from 'lwc';
import getAnswerStats from '@salesforce/apex/QuizController.getAnswerStats';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chart';
import chartjsPluginDatalabels from '@salesforce/resourceUrl/chartjsPluginDatalabels';
import { reduceErrors } from 'c/errorUtils';

const ANSWER_LABELS = ['A', 'B', 'C', 'D'];

export default class AnswerBarChart extends LightningElement {
    answerStats;
    error;

    @api correctAnswer; // A, B, C, or D

    chart;
    chartjsInitialized = false;

    connectedCallback() {
        getAnswerStats()
            .then((data) => {
                this.answerStats = ANSWER_LABELS.map((label) => data[label]);
                this.error = undefined;
            })
            .catch((error) => {
                this.error = reduceErrors(error);
                this.answerStats = undefined;
            });
    }

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
                        labels: ANSWER_LABELS,
                        datasets: [
                            {
                                label: '# of Answers per Type',
                                data: this.answerStats,
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
            .catch((error) => {
                this.answerStats = undefined;
                this.error = error;
            });
    }

    renderedCallback() {
        if (
            this.chartjsInitialized ||
            !this.answerStats ||
            !this.correctAnswer
        ) {
            return;
        }
        this.chartjsInitialized = true;
        this.renderGraph();
    }
}
