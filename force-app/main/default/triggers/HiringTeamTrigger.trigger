/**
 * @description       : Trigger for Hiring Team object. Runs on after insert and after update
 * @author            : Tyler Riden
 * @group             : Cloud Smiths
 * @last modified on  : 08-01-2024
 * @last modified by  : Tyler Riden
**/
trigger HiringTeamTrigger on Hiring_Team__c (after insert, after update) {
    HiringTeamHandler handler = new HiringTeamHandler();
    handler.run();
}