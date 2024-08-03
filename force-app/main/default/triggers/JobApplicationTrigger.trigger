/**
 * @description       : Trigger for Job Application object. Runs on before insert, after insert, and after update
 * @author            : Tyler Riden
 * @group             : Cloud Smiths
 * @last modified on  : 08-01-2024
 * @last modified by  : Tyler Riden
**/
trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, after update) {
    JobApplicationHandler handler = new JobApplicationHandler();
    handler.run();
}