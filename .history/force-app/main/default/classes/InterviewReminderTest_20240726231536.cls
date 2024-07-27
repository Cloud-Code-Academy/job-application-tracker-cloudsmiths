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

        for (Integer i = 0; i < numRecords; i++) {
            Event e = new Event();
            e.OwnerId = jobApps[i].OwnerId;
            e.Location = jobApps[i].Location__c;
            e.Subject = 'Interview';
            e.WhoId = jobApps[i].Primary_Contact__c;
            e.WhatId = jobApps[i].Id;
            if (jobApps[i].Application_Date__c == Date.today()) {
                e.Interview_Type__c = 'Screening Interview';
                e.Interview_Format__c = 'Phone';
                e.StartDateTime = DateTime.now().addDays(1).addHours(i);
                e.EndDateTime = e.StartDateTime.addHours(1);
            } else if (jobApps[i].Application_Date__c == Date.today().addDays(-40)) {
                e.Interview_Type__c = 'Panel Interview';
                e.Interview_Format__c = 'Video';
                e.StartDateTime = DateTime.now().addDays(-39).addHours(i);
                e.EndDateTime = e.StartDateTime.addHours(1);
            } else if (jobApps[i].Application_Date__c == Date.today().addDays(-60)) {
                e.Interview_Type__c = 'Technical Interview';
                e.Interview_Format__c = 'On-Site';
                e.StartDateTime = DateTime.now().addDays(-59).addHours(i);
                e.EndDateTime = e.StartDateTime.addHours(1);
            } else {
                e.Interview_Type__c = 'Hiring Manager Interview';
                e.Interview_Format__c = 'On-Site';
                e.StartDateTime = DateTime.now().addDays(i).addHours(i);
                e.EndDateTime = e.StartDateTime.addHours(1);
            }
            interviews.add(e);
        }
        Database.insert(interviews, AccessLevel.SYSTEM_MODE);
    }

}