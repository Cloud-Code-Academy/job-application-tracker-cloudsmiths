public with sharing class HiringTeamHandler extends TriggerHandler{

    private List<Hiring_Team__c> newHiringTeam;
    private List<Hiring_Team__c> oldHiringTeam;
    private Map<Id, Hiring_Team__c> newHiringTeamMap;
    private Map<Id, Hiring_Team__c> oldHiringTeamMap;
    
    public HiringTeamHandler() {

        this.newHiringTeam = (List<Hiring_Team__c>) Trigger.new;
        this.oldHiringTeam = (List<Hiring_Team__c>) Trigger.old;
        this.newHiringTeamMap = (Map<Id, Hiring_Team__c>) Trigger.newMap;
        this.oldHiringTeamMap = (Map<Id, Hiring_Team__c>) Trigger.oldMap;
    }

    public override void afterInsert(){
        List<Job_Application__c> jobAppsToUpdate = setApplicationPrimaryContact(newHiringTeam);
        List<Hiring_Team__c> hiringTeamsToUpdate = updatePreviousPrimaryContact(newHiringTeam);
        
        TriggerHandler.bypass('JobApplicationHandler');
        Database.update(jobAppsToUpdate, AccessLevel.USER_MODE);
        TriggerHandler.bypass('HiringTeamHandler');
        Database.update (hiringTeamsToUpdate,AccessLevel.USER_MODE);
        TriggerHandler.clearAllBypasses();
    }

    public override void afterUpdate(){
        List<Job_Application__c> jobAppsToUpdate = new List<Job_Application__c>();
        List<Job_Application__c> setAppPrimaryContact = setApplicationPrimaryContact(newHiringTeam);
        List<Job_Application__c> removeAppPrimaryContact = removePrimaryContact(newHiringTeamMap,oldHiringTeamMap);
        jobAppsToUpdate.addAll(setAppPrimaryContact);
        jobAppsToUpdate.addAll(removeAppPrimaryContact);
        List<Hiring_Team__c> hiringTeamsToUpdate = updatePreviousPrimaryContact(newHiringTeam);

        TriggerHandler.bypass('JobApplicationHandler');
        Database.update (jobAppsToUpdate, AccessLevel.USER_MODE);
        TriggerHandler.bypass('HiringTeamHandler');
        Database.update (hiringTeamsToUpdate,AccessLevel.USER_MODE);
        TriggerHandler.clearAllBypasses();
    }

    public static List<Job_Application__c> setApplicationPrimaryContact(List<Hiring_Team__c> newHiringTeam){
        //Create map of Job Application Ids and Primary Contact Ids
        Map<Id,Id> jobAppIdToPrimaryContactIdMap = new Map<Id,Id>();
        //Create List of Job App Ids to be used in SOQL Query
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
        
        return jobAppsToUpdate;
    }

    public static List<Job_Application__c> removePrimaryContact(Map<Id, Hiring_Team__c> newHiringTeamMap, Map<Id, Hiring_Team__c> oldHiringTeamMap){
        List<Id> jobAppIds = new List<Id>();
        for(Hiring_Team__c teamMember :newHiringTeamMap.values()){
            if(oldHiringTeamMap.get(teamMember.Id).Primary_Contact__c == true && teamMember.Primary_Contact__c == false){
                jobAppIds.add(teamMember.Job_Application__c);
            }
        }
        List<Job_Application__c> jobAppUpdates = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobAppIds];
        for(Job_Application__c jobApp :jobAppUpdates){
            jobApp.Primary_Contact__c = null;
        }
        return jobAppUpdates;
    }

    public static List<Hiring_Team__c> updatePreviousPrimaryContact(List<Hiring_Team__c> newHiringTeam){
        List<Id> jobAppIds = new List<Id>();
        List<Id> newHiringTeamIds = new List<Id>();
        for(Hiring_Team__c teamMember :newHiringTeam){
            jobAppIds.add(teamMember.Job_Application__c);
            newHiringTeamIds.add(teamMember.Id);
        }
        List<Hiring_Team__c> existingHiringTeamList = [SELECT Id, Contact__c, Primary_Contact__c FROM Hiring_Team__c WHERE Job_Application__c IN :jobAppIds AND Id NOT IN :newHiringTeamIds AND Primary_Contact__c = true];
        System.debug(existingHiringTeamList);
        for(Hiring_Team__c teamMember :existingHiringTeamList){
            teamMember.Primary_Contact__c = false;
        }
        return existingHiringTeamList;
    
    }
}