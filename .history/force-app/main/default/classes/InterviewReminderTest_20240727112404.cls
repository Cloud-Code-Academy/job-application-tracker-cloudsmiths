/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-27-2024
 * @last modified by  : Riley Meyer
**/
@IsTest
private class InterviewReminderTest {
    @TestSetup
    static void makeData(){
        Integer numRecords = 400;
        List<User> users = TestDataFactory.createUsers(numRecords);
        List<Account> accounts = TestDataFactory.createAccounts(numRecords);
        List<Contact> contacts = TestDataFactory.createContacts(accounts, numRecords);
        List<Job_Application__c> jobApps = TestDataFactory.createJobApplications(users, accounts, contacts, numRecords);
        List<Event> interviews = TestDataFactory.createInterviews(jobApps, numRecords);
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW];
        Set<Id> jobAppIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            jobAppIds.add(interview.WhatId);
        }
        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c, Primary_Contact__c, Location__c, Location_Type__c, Job_Type__c, Salary__c, Salary_Type__c, Job_Posting_URL__c, Rating_Scale__c
                                                        FROM Job_Application__c
                                                        WHERE Id IN :jobAppIds]);
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

        Test.startTest();
        Map<Id, Account> idToAccount = InterviewReminder.getAccountRecords(jobIdToJobApp);
        Test.stopTest();

        for (Job_Application__c jobApp : jobIdToJobApp.values()) {
            System.assertEquals(true, idToAccount.containsKey(jobApp.Company__c), 'Get Account Records did not find all Accounts');
        }
    }
}