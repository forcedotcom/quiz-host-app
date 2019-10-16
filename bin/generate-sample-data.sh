#!/bin/bash
SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd $SCRIPT_PATH

sfdx force:data:tree:export --query \
    "SELECT Id, Label__c, Answer_A__c, Answer_B__c, Answer_C__c, Answer_D__c, Correct_Answer__c, \
        (SELECT Id, Phase__c, Current_Question__c FROM Quiz_Sessions__r), \
        (SELECT Id, Question_Index__c, Session__c, Question__c FROM Session__r) \
    FROM Quiz_Question__c" \
--outputdir ../data --plan
