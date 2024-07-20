public with sharing class JobApplicationHandler extends TriggerHandler {

    private List<Job_Application__c> newJobApplications;
    private List<Job_Application__c> oldJobApplications;
    private Map<Id, Job_Application__c> newJobApplicationMap;
    private Map<Id, Job_Application__c> oldJobApplicationMap;

    public JobApplicationHandler() {

        this.newJobApplications = (List<Job_Application__c>) Trigger.new;
        this.oldJobApplications = (List<Job_Application__c>) Trigger.old;
        this.newJobApplicationMap = (Map<Id, Job_Application__c> ) Trigger.newMap;
        this.oldJobApplicationMap = (Map<Id, Job_Application__c> ) Trigger.oldMap;
    }

    public override void beforeInsert(){
         setPrimaryContact(newJobApplications);

    }

    public override void afterInsert(){
        List<Hiring_Team__c> hiringTeamList = createMissingHiringTeam(newJobApplications);
        TriggerHandler.bypass('HiringTeamHandler');
        insert hiringTeamList;
        TriggerHandler.clearAllBypasses();
    }

    public static void setPrimaryContact(List<Job_Application__c> newJobApplications){
        List<Id> accountIdList = new List<Id>();
        Map<Id,Id> accountIdByJobAppIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :newJobApplications){
            accountIdList.add(jobApp.Company__c);
            accountIdByJobAppIdMap.put(jobApp.Id, jobApp.Company__c);
        }
        List<Contact> contactList = [SELECT Id, Name, CreatedDate,AccountId FROM Contact WHERE AccountId IN :accountIdList Order By CreatedDate ASC];
        Map<Id,Id> contactIdByAccountIdMap = new Map<Id,Id>();
        for(Contact con :contactList){
            if(!contactIdByAccountIdMap.containsKey(con.AccountId)){
                contactIdByAccountIdMap.put(con.AccountId,con.Id);
            }
        }

        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c == null && accountIdByJobAppIdMap.containsKey(jobApp.Id) && contactIdByAccountIdMap.containsKey(jobApp.Company__c)){
                jobApp.Primary_Contact__c = contactIdByAccountIdMap.get(jobApp.Company__c);
            }
        }
    }

    public static List<Hiring_Team__c> createMissingHiringTeam(List<Job_Application__c> newJobApplications){
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        List<Id> jobAppId = new List<Id>();
        List<Id> primaryContactId = new List<Id>();
        Map<Id,Id> contactByJobAppIdMap = new Map<Id,Id>();
        Map<Id,Id> existingContactByJobAppIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c != null){
                primaryContactId.add(jobApp.Primary_Contact__c);
                jobAppId.add(jobApp.Id);
                contactByJobAppIdMap.put(jobApp.Id, jobApp.Primary_Contact__c);
            }
        }

        for(Job_Application__c jobApp :newJobApplications){
            if(existingContactByJobAppIdMap.containsKey(jobApp.Id) || jobApp.Primary_Contact__c == null){
                continue;
            }
            Hiring_Team__c newHiringTeam = new Hiring_Team__c (Job_Application__c = jobApp.Id, Contact__c = contactByJobAppIdMap.get(jobApp.Id), Primary_Contact__c = true);
            hiringTeamList.add(newHiringTeam);
        }
        return hiringTeamList;
    }
}