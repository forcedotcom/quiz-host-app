# Multiplayer quiz app built on Salesforce technology (host app)

[![Github Workflow](<https://github.com/pozil/quiz-host-app/workflows/Salesforce%20DX%20CI%20(scratch%20org%20only)/badge.svg?branch=master>)](https://github.com/pozil/quiz-host-app/actions)

1. [About](#about)
1. [Installation](#installation)
   - [Requirements](#requirements)
   - [Steps](#steps)
1. [Building and contributing](#building-and-contributing)

## About

This application is a multiplayer game entirely built on Salesforce technology. A game host presents questions from a Salesforce Org on a shared screen or a video projector. Players compete by answering those questions in real-time using a Lightning Web Component Open Source mobile application hosted on Heroku. The fastest player to give the correct answer scores the most points. As the game progresses, leaderboards are displayed so that players can keep track of scores and ranks.

The quiz app was launched during Developer Game Night at Dreamforce 2019.

<img src="doc-media/registration.jpg" alt="Quiz registration at Dreamforce 2019"/><br/>
<img src="doc-media/question-host.jpg" width="500" alt="Quiz host app showing question"/>
<img src="doc-media/question-player.png" width="200" alt="Quiz player app showing answer buttons"/>
<img src="doc-media/leaderboard.jpg" width="500" alt="Quiz leaderboard at Dreamforce 2019"/>

## Installation

### Requirements
The quiz requires two applications: a host app and a player app.

The host app is a Lightning Web Component (LWC) app running on a Salesforce Org.
You'll need a free [Salesforce Developer Edition (DE)](https://developer.salesforce.com/signup) org or a [scratch org]().

The player app is a mobile app built with Lightning Web Component Open Source (LWC OSS). It runs on Node.js  depoyed on Heroku.
You'll need a free [Heroku account](https://signup.heroku.com) to set it up.

### Steps

<ol>
    <li>Run <code>install-dev.sh</code> to deploy the host app on a scratch org</li>
    <li>Generate a <a target="_blank" href="https://help.salesforce.com/articleView?id=user_security_token.htm">security token</a> for your user</li>
    <li>Deploy the <b>Quiz Player App</b> to Heroku by clicking this button:<br/>
      <p align="center">
        <a target="_blank" href="https://heroku.com/deploy?template=https://github.com/pozil/quiz-player-app/edit/master" title="Deploy to Heroku">
          <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy to Heroku"/>
        </a>
      <p>
    </li>
    <li>In your Salesforce org, go to <b>Setup &gt; Remote Site Settings</b> and add the player app URL.</li>
    <li>Go to <b>Setup &gt; Custom Metadata Types</b> and add a <b>Quiz Settings</b> record.</li>
</ol>

## Building and contributing

If you want to build the project from sources and contribute, run `npm install` to install the project build tools.

Here is the [Quiz Player App](https://github.com/pozil/quiz-player-app).
