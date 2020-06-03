<div align="center">
  <img src="doc-media/quiz-icon.png" alt="Quiz icon" width="150"/>
</div>

# Multiplayer quiz app built on Salesforce technology (host app)

[![GitHub Workflow](https://github.com/pozil/quiz-host-app/workflows/CI/badge.svg?branch=master)](https://github.com/pozil/quiz-host-app/actions) [![GitHub Workflow](https://github.com/pozil/quiz-host-app/workflows/Packaging/badge.svg)](https://github.com/pozil/quiz-host-app/actions) [![codecov](https://codecov.io/gh/pozil/quiz-host-app/branch/master/graph/badge.svg)](https://codecov.io/gh/pozil/quiz-host-app)

1. [About](#about)
1. [Installation](#installation)
    - [Requirements](#requirements)
    - [Host App Installation](#host-app-installation)
    - [Player App Installation](#player-app-installation)
    - [Questions Setup](#questions-setup)
1. [Playing](#playing)
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

The host app is a Lightning Web Component (LWC) app running on a Salesforce org.

The player app is a mobile app built with Lightning Web Component Open Source (LWC OSS). It runs on Node.js deployed on Heroku.
You'll need a free [Heroku account](https://signup.heroku.com) to set it up. A free account lets you run the game with a small group of players. If you run the game with a larger group, consider upgrading to a [Hobby Dyno](https://www.heroku.com/dynos).

<img src="doc-media/architecture.jpg" alt="Quiz app architecture"/>

### Host App Installation

There are two installation options for the host app:

#### Option 1: Managed Package (recommended)

1. Click [this link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t0N000001Bl41QAC) to install the host app package and choose **Install for All Users**.

    You'll need to approve access to `https://chart.googleapis.com`. We use this library to draw leaderboads.

1. Set up permissions:
    1. Navigate to **Setup > Users > Permission Sets**, click **Quiz Host**
    1. Click **Manage Assignements**
    1. Click **Add Assignement**
    1. Check your user and click **Assign**.
1. Navigate to **Setup > Integrations > Change Data Capture**, enable Change Data Capture for the **Quiz Player** object and **Save**.
1. Using the App Switcher, navigate to the **Quiz** Lightning app.
1. Select the **Quiz Sessions** tab and click **New**. Leave the default values and create a Quiz Session record.
1. Continue setup by [installing the player app](#player-app-installation)

#### Option 2: Scratch Org (for development purposes)

We assume that you have a working Salesforce DX environment (Salesforce CLI installed, Dev Hub configured and authorized). See this [Trailhead project](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_app_dev/sfdx_app_dev_setup_dx) for guided steps.

1. Open a Terminal and clone the git repository:

    ```
    git clone https://github.com/pozil/quiz-host-app.git
    cd quiz-host-app
    ```

1. Run the installation script. The script deploys the quiz host app on a scratch org with a `quiz` alias and pre-loads `sample` questions.

    MacOS or Linux

    ```
    ./install-dev.sh quiz sample
    ```

    Windows

    ```
    install-dev.bat quiz sample
    ```

    Once the script completes, it will open your new scratch org in a browser tab. If you close the tab or get disconnected, run this command to reopen the org `sfdx force:org:open -u quiz`

1. Continue setup by [installing the player app](#player-app-installation)

### Player App Installation

1. Generate a [security token](https://help.salesforce.com/articleView?id=user_security_token.htm) for your Salesforce user.
1. Generate a secure password using [this service](https://passwordsgenerator.net/) or any other. This will be the secret **Quiz API Key** that you'll set later in both applications.
1. Deploy the **Quiz Player App** to Heroku by clicking this button:
   <a target="_blank" href="https://heroku.com/deploy?template=https://github.com/pozil/quiz-player-app/edit/master" title="Deploy to Heroku">
   <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy to Heroku"/>
   </a>

1. Set the <b>Config Vars</b> for the Heroku Player app as following:

    | Variable                | Description                                                                                                                                                                     |
    | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `QUIZ_API_KEY`          | The Quiz API key.                                                                                                                                                               |
    | `SF_LOGIN_URL`          | The login URL of your Salesforce org:<br>`https://test.salesforce.com/` for scratch orgs and sandboxes<br/>`https://login.salesforce.com/` for Developer Edition and production |
    | `SF_PASSWORD`           | Your Salesforce user's password.                                                                                                                                                |
    | `SF_TOKEN`              | Your Salesforce user's security token.                                                                                                                                          |
    | `SF_USERNAME`           | Your Salesforce username.                                                                                                                                                       |
    | `COLLECT_PLAYER_EMAILS` | Whether the app should collect player emails (true/false).                                                                                                                      |

1. Generate a minified URL for the Heroku player app using [this service](https://bit.do/) or any other URL shortener (opt for a custom link for greater readability).
1. In your Salesforce org, go to **Setup > Remote Site Settings** and add the complete player app URL (not the minified URL).
1. Go to **Setup > Custom Metadata Types** and add a **Quiz Settings** record. Set it up with these values:

    | Field                     | Description                                               |
    | ------------------------- | --------------------------------------------------------- |
    | `Player App URL`          | The Heroku player app URL.                                |
    | `Player App URL Minified` | The minified URL for the player app.                      |
    | `Quiz API Key`            | The password that was generated earlier.                  |
    | `Question Timer`          | The duration of the question timer (default: 12 seconds). |

### Questions Setup

Questions are stored as `Quiz_Question__c` records. You can create or import questions by adding records manually or by importing them a CSV or XLS files with the [Data Import Wizard](https://help.salesforce.com/apex/HTViewHelpDoc?id=data_import_wizard.htm).

You org should have one and only one `Quiz_Session__c` record. This records controls the list of selected questions and specifies the questions' order.

#### Importing Questions Using the Salesforce CLI

You can import questions with the Salesforce CLI.

1. Get a zip with custom questions and extract in the `data` folder. Assuming that your custom question folder is named `CUSTOM_QUESTIONS`, you should have the following files and folders:

    ```
    /data
    /CUSTOM_QUESTIONS
        /plan.json
        /Quiz_Question__cs.json
        /Quiz_Session__cs.json
        /Quiz_Session_Question__cs.json
    ```

1. Run this script to remove existing questions:

    ```
    sfdx force:apex:execute -f bin/wipe-data.apex
    ```

1. Run this script from the project root to import your custom questions:

    ```
    sfdx force:data:tree:import -p data/CUSTOM_QUESTIONS/plan.json
    ```

## Playing

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

The default player app installation uses Heroku. Heroku datacenters are only available in North America and Europe. If you are running the quiz from another region (i.e.: India, Australia...), there's a good chance that your player will experience some lag. Consider switching to another cloud provider that lets you run a Node.js environment.

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
