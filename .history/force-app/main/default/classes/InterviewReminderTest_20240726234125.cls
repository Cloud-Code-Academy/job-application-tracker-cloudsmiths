/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Riley Meyer
**/
@IsTest
private class InterviewReminderTest {
    @TestSetup
    static void makeData(){
        Integer numRecords = 250;
        List<User> users = TestDataFactory.createUsers(numRecords);
        List<Account> accounts = TestDataFactory.createAccounts(numRecords);
        List<Contact> contacts = TestDataFactory.createContacts(accounts, numRecords);
        List<Job_Application__c> jobApps = TestDataFactory.createJobApplications(users, accounts, contacts, numRecords);
        List<Event> interviews = TestDataFactory.createInterviews(jobApps, numRecords);
    }

    @isTest
    static void sendEmailReminerTest(){
        Test.startTest();
        Test.stopTest();
    }

    @isTest
    static void getScheduledInterviewsTest(){
        Test.startTest();
        Test.stopTest();
    }

    @isTest
    static void getJobApplicationRecordsTest(){
        Test.startTest();
        Test.stopTest();
    }

    @isTest
    static void getEmailAddressesTest(){
        Test.startTest();
        Test.stopTest();
    }

    @isTest
    static void getContactRecordsTest(){
        Test.startTest();
        Test.stopTest();
    }

    @isTest
    static void getAccountRecordsTest(){
        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>();
        for (Job_Application__c jobApp : jobApps) {
            jobIdToJobApp.put(jobApp.Id, jobApp);
        }

        Test.startTest();
        Map<Id, Account> idToAccount = InterviewReminder.getAccountRecords(jobIdToJobApp);
        Test.stopTest();

        for (Job_Application__c jobApp : jobApps) {
            System.assertEquals(true, idToAccount.containsKey(jobApp.Company__c), 'Get Account Records did not find all Accounts');
        }
    }
}