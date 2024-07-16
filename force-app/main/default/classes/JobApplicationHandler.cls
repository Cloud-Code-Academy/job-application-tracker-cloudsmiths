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

    public void setPrimaryContact(List<Job_Application__c> newJobApplications){
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

}