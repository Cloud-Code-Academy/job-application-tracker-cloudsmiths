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
        
    }

    @isTest
    static void getScheduledInterviewsTest(){

    }

    @isTest
    static void getJobApplicationRecordsTest(){

    }

    @isTest
    static void getEmailAddressesTest(){

    }

    @isTest
    static void getContactRecordsTest(){

    }

    @isTest
    static void getAccountRecordsTest(){

        
    }
}