public with sharing class JobApplicationHandler extends TriggerHandler {

    //Initialize variables 
    private List<Job_Application__c> newJobApplications;
    private List<Job_Application__c> oldJobApplications;
    private Map<Id, Job_Application__c> newJobApplicationMap;
    private Map<Id, Job_Application__c> oldJobApplicationMap;

    //Setting variables with values from trigger
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
        Database.insert (hiringTeamList, AccessLevel.SYSTEM_MODE);
        TriggerHandler.clearAllBypasses();
    }

    public static void setPrimaryContact(List<Job_Application__c> newJobApplications){
        //Initialize list of Account Ids and map of Account Ids by Job Application Ids and populate the list and map
        List<Id> accountIdList = new List<Id>();
        Map<Id,Id> accountIdByJobAppIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :newJobApplications){
            accountIdList.add(jobApp.Company__c);
            accountIdByJobAppIdMap.put(jobApp.Id, jobApp.Company__c);
        }
        //Use Account Id list to query list of Contact
        List<Contact> contactList = [SELECT Id, Name, CreatedDate,AccountId FROM Contact WHERE AccountId IN :accountIdList Order By CreatedDate ASC];
        //Initialize map of Contact Ids by Account Ids and populate the map
        Map<Id,Id> contactIdByAccountIdMap = new Map<Id,Id>();
        for(Contact con :contactList){
            if(!contactIdByAccountIdMap.containsKey(con.AccountId)){
                contactIdByAccountIdMap.put(con.AccountId,con.Id);
            }
        }

        /**For each Job Application if Primary Contact is null, the Job Application is in the Account Id map, 
        and the Account is in the Contact Id map, set the Primary Contact
        **/
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c == null && accountIdByJobAppIdMap.containsKey(jobApp.Id) && contactIdByAccountIdMap.containsKey(jobApp.Company__c)){
                jobApp.Primary_Contact__c = contactIdByAccountIdMap.get(jobApp.Company__c);
            }
        }
    }

    public static List<Hiring_Team__c> createMissingHiringTeam(List<Job_Application__c> newJobApplications){
        //Initialze lists of Hiring Team and Job Application Ids
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        List<Id> jobAppId = new List<Id>();
        //Initialize map of Contacts by Job Application Id 
        Map<Id,Id> contactByJobAppIdMap = new Map<Id,Id>();
        //Populate the Job Application Id list and map
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c != null){
                jobAppId.add(jobApp.Id);
                contactByJobAppIdMap.put(jobApp.Id, jobApp.Primary_Contact__c);
            }
        }

        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c == null){
                continue;
            }
            Hiring_Team__c newHiringTeam = new Hiring_Team__c (Job_Application__c = jobApp.Id, Contact__c = contactByJobAppIdMap.get(jobApp.Id), Primary_Contact__c = true);
            hiringTeamList.add(newHiringTeam);
        }
        return hiringTeamList;
    }
}