/**
 * @description       : Handler class for the Hiring Team object trigger
 * @author            : Tyler Riden
 * @group             : Cloud Smiths
 * @last modified on  : 08-01-2024
 * @last modified by  : Tyler Riden
**/
public with sharing class HiringTeamHandler extends TriggerHandler{
    //Initialize variables    
    private List<Hiring_Team__c> newHiringTeam;
    private List<Hiring_Team__c> oldHiringTeam;
    private Map<Id, Hiring_Team__c> newHiringTeamMap;
    private Map<Id, Hiring_Team__c> oldHiringTeamMap;
    
    //Setting variables with values from trigger
    public HiringTeamHandler() {
        this.newHiringTeam = (List<Hiring_Team__c>) Trigger.new;
        this.oldHiringTeam = (List<Hiring_Team__c>) Trigger.old;
        this.newHiringTeamMap = (Map<Id, Hiring_Team__c>) Trigger.newMap;
        this.oldHiringTeamMap = (Map<Id, Hiring_Team__c>) Trigger.oldMap;
    }

    public override void afterInsert(){
        List<Job_Application__c> jobAppsToUpdate = setApplicationPrimaryContact(newHiringTeam);
        List<Hiring_Team__c> hiringTeamsToUpdate = updatePreviousPrimaryContact(newHiringTeam);
        
        //Bypasses JobApplicationHandler and HiringTeamHandler to prevent recursion
        TriggerHandler.bypass('JobApplicationHandler');
        Database.update(jobAppsToUpdate, AccessLevel.SYSTEM_MODE);
        TriggerHandler.bypass('HiringTeamHandler');
        Database.update (hiringTeamsToUpdate,AccessLevel.SYSTEM_MODE);
        TriggerHandler.clearAllBypasses();
    }

    public override void afterUpdate(){
        List<Job_Application__c> jobAppsToUpdate = new List<Job_Application__c>();
        List<Job_Application__c> setAppPrimaryContact = setApplicationPrimaryContact(newHiringTeam);
        List<Job_Application__c> removeAppPrimaryContact = removePrimaryContact(newHiringTeamMap,oldHiringTeamMap);
        jobAppsToUpdate.addAll(setAppPrimaryContact);
        jobAppsToUpdate.addAll(removeAppPrimaryContact);
        List<Hiring_Team__c> hiringTeamsToUpdate = updatePreviousPrimaryContact(newHiringTeam);
        //Bypasses JobApplicationHandler and HiringTeamHandler to prevent recursion
        TriggerHandler.bypass('JobApplicationHandler');
        Database.update (jobAppsToUpdate, AccessLevel.SYSTEM_MODE);
        TriggerHandler.bypass('HiringTeamHandler');
        Database.update (hiringTeamsToUpdate,AccessLevel.SYSTEM_MODE);
        TriggerHandler.clearAllBypasses();
    }

    public static List<Job_Application__c> setApplicationPrimaryContact(List<Hiring_Team__c> newHiringTeam){
        //Initialize map of Job Application Ids and Primary Contact Ids
        Map<Id,Id> jobAppIdToPrimaryContactIdMap = new Map<Id,Id>();
        List<Id> jobAppIds = new List<Id>();
    
        //Identify Hiring Team records set as Primary Contacts and add to map
        for(Hiring_Team__c teamMember :newHiringTeam){
            if(teamMember.Primary_Contact__c == true){
                jobAppIdToPrimaryContactIdMap.put(teamMember.Job_Application__c,teamMember.Contact__c);
                jobAppIds.add(teamMember.Job_Application__c);
            }
        }
        
        //Create List of Job Applications to update
        List<Job_Application__c> jobAppsToUpdate = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobAppIds];
        for(Job_Application__c jobApp :jobAppsToUpdate){
            jobApp.Primary_Contact__c = jobAppIdToPrimaryContactIdMap.get(jobApp.Id);
        }
        
        //Return list
        return jobAppsToUpdate;
    }

    public static List<Job_Application__c> removePrimaryContact(Map<Id, Hiring_Team__c> newHiringTeamMap, Map<Id, Hiring_Team__c> oldHiringTeamMap){
        //Initialize list of Job Application Ids and populate list from Hiring Team records if Primay Contact was changed from true to false
        List<Id> jobAppIds = new List<Id>();
        for(Hiring_Team__c teamMember :newHiringTeamMap.values()){
            if(oldHiringTeamMap.get(teamMember.Id).Primary_Contact__c == true && teamMember.Primary_Contact__c == false){
                jobAppIds.add(teamMember.Job_Application__c);
            }
        }
        //Use jobAppIds list to query Job Application records and update Primary Contact to null
        List<Job_Application__c> jobAppUpdates = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobAppIds];
        for(Job_Application__c jobApp :jobAppUpdates){
            jobApp.Primary_Contact__c = null;
        }
        return jobAppUpdates;
    }

    public static List<Hiring_Team__c> updatePreviousPrimaryContact(List<Hiring_Team__c> newHiringTeam){
        //Initialize list of Job Application and Hiring Team Ids and populate the lists
        List<Id> jobAppIds = new List<Id>();
        List<Id> newHiringTeamIds = new List<Id>();
        for(Hiring_Team__c teamMember :newHiringTeam){
            jobAppIds.add(teamMember.Job_Application__c);
            newHiringTeamIds.add(teamMember.Id);
        }
        //Query for Hiring Team records that where Job Application Id is in the list but Hiring Team Id is not
        List<Hiring_Team__c> existingHiringTeamList = [SELECT Id, Contact__c, Primary_Contact__c FROM Hiring_Team__c WHERE Job_Application__c IN :jobAppIds AND Id NOT IN :newHiringTeamIds AND Primary_Contact__c = true];
        //Set Primary Contact to null
        for(Hiring_Team__c teamMember :existingHiringTeamList){
            teamMember.Primary_Contact__c = false;
        }
        //Return list
        return existingHiringTeamList;
    }
}