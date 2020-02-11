<div align="center">
  <img src="doc-media/quiz-icon.png" alt="Quiz icon" width="150"/>
</div>

# Multiplayer quiz app built on Salesforce technology (host app)

[![GitHub Workflow](https://github.com/pozil/quiz-host-app/workflows/CI/badge.svg?branch=master)](https://github.com/pozil/quiz-host-app/actions)

1. [About](#about)
1. [Installation](#installation)
    - [Requirements](#requirements)
    - [Steps](#steps)
    - [Setting up questions](#setting-up-questions)
1. [Usage](#usage)
1. [Troubleshooting](#troubleshooting)
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
You'll need to set up Salesforce DX to deploy it.

The player app is a mobile app built with Lightning Web Component Open Source (LWC OSS). It runs on Node.js deployed on Heroku.
You'll need a free [Heroku account](https://signup.heroku.com) to set it up.

<img src="doc-media/architecture.jpg" alt="Quiz app architecture"/>

### Steps

🎥 [Watch the installation video](https://youtu.be/oDXUMldi0lw)

<ol>
    <li>Set up your Salesforce DX environment:
      <ul>
        <li><a href="https://developer.salesforce.com/tools/sfdxcli">Install Salesforce CLI</a></li>
        <li>Enable <a href="https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.htm">Dev Hub</a> on a Salesforce org. You can do that on a <a href="https://developer.salesforce.com/signup">free Developer Edition</a>.</li>
        <li>Authenticate with your Dev Hub org and provide it with an alias (<b>myhuborg</b> in the command below):
<pre>sfdx force:auth:web:login -d -a myhuborg</pre>
    </li>
      </ul>
    </li>
    <li>Open a Terminal and clone the git repository:
<pre>git clone https://github.com/pozil/quiz-host-app.git
cd quiz-host-app</pre>
<p>Tip: you can also download the files from the website if you don't want to install git.</p>
    </li>
    <li><p>Run the installation script. The script deploys the quiz host app on a scratch org with a <code>quiz</code> alias and pre-loads <code>sample</code> questions.</p>
    <p>MacOS or Linux</p>
    <pre>./install-dev.sh quiz sample</pre>
    <p>Windows</p>
    <pre>install-dev.bat quiz sample</pre>
    <p>Once the script completes, it will open your new scratch org in a browser tab. If you close the tab or get disconnected, run this command to reopen the org <code>sfdx force:org:open -u quiz</code></p>
    </li>
    <li>Generate a <a target="_blank" href="https://help.salesforce.com/articleView?id=user_security_token.htm">security token</a> for your user</li>
    <li>Generate a password using <a target="_blank" href="https://passwordsgenerator.net/">this service</a>. This will be the secret <b>Quiz API Key</b> that you'll set later in both applications.
    <li>Deploy the <b>Quiz Player App</b> to Heroku by clicking this button:<br/>
      <p align="center">
        <a target="_blank" href="https://heroku.com/deploy?template=https://github.com/pozil/quiz-player-app/edit/master" title="Deploy to Heroku">
          <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy to Heroku"/>
        </a>
      <p>
    </li>
    <li>Set the <b>Config Vars</b> for the Heroku Player app as following:
      <table>
        <tr>
          <th>Variable</th>
          <th>Description</th>
        </tr>
        <tr>
          <td>QUIZ_API_KEY</td>
          <td>The Quiz API key that was generated in step 5.</td>
        </tr>
        <tr>
          <td>SF_LOGIN_URL</td>
          <td>The login URL of your Salesforce org:<br/>
          <code>https://test.salesforce.com/</code> for scratch orgs and sandboxes<br/>
          <code>https://login.salesforce.com/</code> for Developer Edition and production</td>
        </tr>
        <tr>
          <td>SF_PASSWORD</td>
          <td>Your Salesforce password.</td>
        </tr>
        <tr>
          <td>SF_TOKEN</td>
          <td>Your Salesforce user's security token that was generated in step 4.</td>
        </tr>
        <tr>
          <td>SF_USERNAME</td>
          <td>Your Salesforce username.</td>
        </tr>
      </table>
    </li>
    <li>Generate a minified URL for the Heroku player app using <a target="_blank" href="https://bit.do/">this service</a> (I suggest a custom link for greater readability).</li>
    <li>In your Salesforce org, go to <b>Setup &gt; Remote Site Settings</b> and add the complete player app URL (not the minified URL).</li>
    <li>Go to <b>Setup &gt; Custom Metadata Types</b> and add a <b>Quiz Settings</b> record. Set it up with these values:
      <table>
      <tr>
        <th>Field</th>
        <th>Description</th>
      </tr>
      <tr>
        <td>Player App URL</td>
        <td>The Heroku player app URL that was generated in step 6.</td>
      </tr>
      <tr>
        <td>Player App URL Minified</td>
        <td>The minified URL for the player app that was generated in step 8.</td>
      </tr>
      <tr>
        <td>Quiz API Key</td>
        <td>The password that was generated in step 5.</td>
      </tr>
      </table>
    </li>
</ol>

### Setting up questions

The default installation provides a limited set of sample questions but you can customize questions as you see fit as these are based on records.

#### Importing other questions

The easiest way to add new questions is to import them using the Salesforce CLI.

1. Get a zip with custom questions and extract in the `data` folder. Assuming that your custom question folder is named `CUSTOM_QUESTIONS`, you should have the following files and:

```
/data
  /CUSTOM_QUESTIONS
    /plan.json
    /Quiz_Question__cs.json
    /Quiz_Session__cs.json
    /Quiz_Session_Question__cs.json
```

2. Run this script to remove existing questions:

```
sfdx force:apex:execute -f bin/wipe-data.apex
```

3. Run this script from the project root to import your custom questions:

```
sfdx force:data:tree:import -p data/CUSTOM_QUESTIONS/plan.json
```

#### Adding/editing questions

You can add or edit `Quiz_Question__c` records to customize the game.

Follow this process to add a new question:

1. Create a `Quiz_Question__c` record with a question label, the four possible answers and a correct answer.
1. Create a `Quiz_Session_Question__c` to tie your `Quiz_Question__c` to the `Quiz_Session__c`. You'll need to specify an unique index number for the question. This index is used to order questions during the game.

**Note:** if you change the first quiz question, make sure to hit the reset button on the quiz host app.

## Usage

🎥 [Watch the playthrough video](https://www.youtube.com/watch?v=vLTZ_jdwhRo)

Once you have installed the app, test it in private to confirm that it works.

Here is how the game works:

1. Open the Salesforce org. You log in with your browser or simply run this command: `sfdx force:org:open -u quiz`
1. Open the **Quiz app** from App Launcher.
1. Make sure that the screen is showing the **Registration** screen. If not, click the **Reset** button.
1. Open the mini URL or scan the QR code with your phone. That should open the player app.
1. Register on the player app. Your player name should automatically appear on the host app.
1. Click on the top right **Start** button on the host app. Once the game is started, players are no longer able to register.
1. Your player app should show a "Waiting for question" message for a few seconds then show the 4 answer buttons. If the player app does not refresh, you likely have a setup issue. See troubleshooting.

**Scoring system**

Players start with a zero score. The fastest player to answer a question correctly earns 1000 points.
Players who also answered correctly but slower will earn a decreasing number of points depending on how late they answered. Wrong answers grant no points. The player that scores the most points at the end of the game wins.

**Player app wake-up**

Shortly before running the official game, make sure to access the player app a first time to load it.<br/>
The default Heroku setup uses a free Heroku dyno. This implies that apps that are inactive for more than 30 minutes are put to sleep. Any connection to the app will wake it up but it takes a bit less than a minute. You may experience some "Request time out" errors during that wake-up time.

If you are running the game with 40+ players, consider upgrading to a [Hobby dyno](https://www.heroku.com/dynos).

**Resetting the game**

You can reset the game at any time by clicking on the Reset button on top right of the Quiz app. This resets the quiz session to the registration phase, clears players and previous answers.

## Troubleshooting

Review these common problems. If you can't find a solution to your problem, [open a new issue](https://github.com/pozil/quiz-host-app/issues).

**Player app is not starting (Heroku error page is displayed)**
-   Check the Heroku app logs for the cause of the error. The app will refuse to start if your Salesforce credentials are incorrect (most likely error).
-   Verify your Salesforce credentials in the configuration variables of your Heroku app.

**Player app is not updating when switching game phase (from registration to question for example)**
-   Check that you have registered the correct Remote Site in your org.
-   Check that your Quiz API Key is correctly set up in both the Custom Metadata Types and in the configuration variables of your Heroku app.

**Player app is slow/lags, questions do not show up on time**
The default player app installation uses Heroku. Heroku datacenters are only available in North America and Europe. If you are running the quiz in Asia or Oceania, there's a good chance that your player will experience some lag. Consider switching to another cloud provider that let's you run a Node.js environment.

**Something is wrong with the quiz data or you'd like to reset it**
-   Reset the game using the Reset button on the quiz app. This resets the quiz session to the registration phase, clears players and previous answers.
-   Run the following script wipe ALL quiz data. You'll have to reimport questions.
    ```
    sfdx force:apex:execute -f bin/wipe-data.apex
    ```

**You're seeing a "Failed to validate Quiz app settings: Read timed out" error on the host app**
Refresh the page to fix the problem. Refer to the **Player app wake-up** section of this document for more information.

## Building and contributing

If you want to build the project from sources and contribute, run `npm install` to install the project build tools.

Here is the [Quiz Player App repository](https://github.com/pozil/quiz-player-app).
