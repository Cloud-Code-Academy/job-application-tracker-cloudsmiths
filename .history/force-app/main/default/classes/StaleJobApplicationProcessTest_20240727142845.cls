/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-27-2024
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

        Test.startTest();
        StaleJobApplicationProcess.updateStaleJobApplications();
        Test.stopTest();

        List<Job_Application__c> staleJobs = [SELECT Id, Status__c, Follow_Up_Date__c, CreatedDate, Notes__c 
                                                FROM Job_Application__c
                                                WHERE (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c <= :System.today().addDays(-30))
                                                        OR (Status__c != 'Closed' AND Status__c != 'Accepted' AND Follow_Up_Date__c = null AND CreatedDate <= :System.today().addDays(-30))];

        System.assertEquals(0, staleJobs.size(), 'Stale Jobs were not updated');
    }
}