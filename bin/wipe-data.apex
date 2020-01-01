/*
WARNING! THIS ANONYMOUS APEX BLOCK WIPES ALL DATA FROM YOUR QUIZ. 
MAKE SURE YOU HAVE A MEANS TO RESTORE THIS IT IF YOU PROCEED! 
*/

delete [SELECT Id FROM Quiz_Session__c];
delete [SELECT Id FROM Quiz_Answer__c];
delete [SELECT Id FROM Quiz_Player__c];
delete [SELECT Id FROM Quiz_Session_Question__c];
delete [SELECT Id FROM Quiz_Question__c];
