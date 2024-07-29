/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-28-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class StaleJobApplicationProcess implements Schedulable {

    /**
    * You can run these lines of code in Developer Console > Apex Anonymous to schedule this Class to run nightly at 1 AM
    * StaleJobApplicationProcess i = new StaleJobApplicationProcess ();
    * String sch = '0 0 1 * * ?';
    * String jobID = System.schedule('Stale JobApp Process', sch, i);
    * System.debug(jobID);
    **/

    // Allows this class to be scheduled nightly to clean up stale jobs
    public void execute (SchedulableContext sc) {
        updateStaleJobApplications();
    }

    @future
    public static void updateStaleJobApplications() {
        // Retrieve stale Job Application Records
        List<Job_Application__c> staleJobs = [SELECT Id, Status__c, Follow_Up_Date__c, CreatedDate, Notes__c 
                                                FROM Job_Application__c
                                                WHERE (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c <= :System.today().addDays(-30))
                                                        OR (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c = null AND CreatedDate <= :System.today().addDays(-30))];

        // Update the Status and the Notes of the stale Job Application records
        for (Job_Application__c job : staleJobs) {
            job.Status__c = 'Closed';
            if (!String.isEmpty(job.Notes__c)) {
                job.Notes__c = 'STALE JOB CLOSED BY AUTOMATED PROCESS\n' + job.Notes__c;
            } else {
                job.Notes__c = 'STALE JOB CLOSED BY AUTOMATED PROCESS';
            }
        }

        Database.upsert(staleJobs, AccessLevel.SYSTEM_MODE);
    }

}