/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 08-01-2024
 * @last modified by  : Riley Meyer
**/
@IsTest
private class StaleJobApplicationProcessTest {
    @TestSetup
    static void makeData(){
        Integer numRecords = 400;
        List<User> users = TestDataFactory.createUsers(numRecords);
        List<Account> accounts = TestDataFactory.createAccounts(numRecords);
        List<Contact> contacts = TestDataFactory.createContacts(accounts, numRecords);
        List<Job_Application__c> jobApps = TestDataFactory.createJobApplications(users, accounts, contacts, numRecords);
        List<Event> interviews = TestDataFactory.createInterviews(jobApps, numRecords);
    }

    @IsTest
    static void updateStaleJobApplicationsTest() {
        List<Job_Application__c> staleJobs = [SELECT Id, Status__c, Follow_Up_Date__c, CreatedDate, Notes__c 
                                                FROM Job_Application__c
                                                WHERE (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c <= :System.today().addDays(-30))
                                                    OR (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c = null AND CreatedDate <= :System.today().addDays(-30))];

        System.assert(staleJobs.size() > 0, 'No stale jobs were created for the test');

        Test.startTest();
        StaleJobApplicationProcess.updateStaleJobApplications();
        Test.stopTest();

        List<Job_Application__c> wereNotesOverriden = new List<Job_Application__c>();
        for (Job_Application__c jobApp : [SELECT Id, Notes__c, Status__c FROM Job_Application__c WHERE Status__c = 'Closed']) {
            if(jobApp.Notes__c.contains('I should set a follow up date.')) {
                wereNotesOverriden.add(jobApp);
            }
        }

        System.assert(wereNotesOverriden.size() > 0, 'The notes field of the stale jobs should have been updated');

        List<Job_Application__c> staleJobsAfterUpdate = [SELECT Id, Status__c, Follow_Up_Date__c, CreatedDate, Notes__c 
                                                        FROM Job_Application__c
                                                        WHERE (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c <= :System.today().addDays(-30))
                                                            OR (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c = null AND CreatedDate <= :System.today().addDays(-30))];

        System.assertEquals(0, staleJobsAfterUpdate.size(), 'Stale Jobs were not updated');
    }

    @IsTest
    static void schedulableTest(){
        Test.startTest();
        StaleJobApplicationProcess staleProcess = new StaleJobApplicationProcess();
        String cron = '0 0 0 15 3 ? 2025';
        String jobId = System.schedule('Stale Job Application Process', cron, staleProcess);
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cron, ct.CronExpression, 'CronExpression does not match');
        System.assertEquals(0, ct.TimesTriggered, 'TimesTriggered does not match');
        System.assertEquals('2025-03-15 00:00:00', String.valueOf(ct.NextFireTime), 'NextFireTime does not match');
    }
}