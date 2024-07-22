/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-21-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class StaleJobApplicationProcess {

    @future
    public static void updateStaleJobApplications() {
        List<Job_Application__c> staleJobs = [SELECT Id, Status__c, Follow_Up_Date__c, CreatedDate, Notes__c 
                                                FROM Job_Application__c
                                                WHERE (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c <= :System.today().addDays(-30))
                                                        OR (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c = null AND CreatedDate <= :System.today().addDays(-30))];
        
        for (Job_Application__c job : staleJobs) {
            job.Status__c = 'Closed';
            job.Notes__c = 'STALE JOB CLOSED BY AUTOMATED PROCESS' + job.Notes__c;
        }

        Database.upsert(staleJobs, AccessLevel.SYSTEM_MODE);
    }

}