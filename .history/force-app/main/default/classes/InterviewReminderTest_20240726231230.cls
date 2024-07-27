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
        List<Event> interviews = new List<Event>();

        for (Integer i = 0; i < numRecords; i++) {
            Job_Application__c j = new Job_Application__c();
            j.OwnerId = users[i].Id;
            j.Status__c = 'Saved';
            j.Company__c = accounts[i].Id;
            j.Primary_Contact__c = contacts[i].Id;
            j.Position_Title__c = 'Developer' + i + 'at' + accounts[i].Name;
            j.Description__c = 'Dummy Job Description';
            j.Job_Posting_URL__c = 'https://jooble.org';
            if (i < 100) {
                j.Job_Type__c = 'Full-time';
                j.Salary__c = 150;
                j.Salary_Type__c = 'Annual';
                j.Location__c = 'Miami, FL';
                j.Location_Type__c = 'On-Site';
                j.Application_Date__c = Date.today();
                j.Follow_Up_Date__c = null;
                j.Rating_Scale__c = '2';
            } else if (i < 200) {
                j.Job_Type__c = 'Part-time';
                j.Salary__c = 58;
                j.Salary_Type__c = 'Hourly';
                j.Location__c = 'Omaha, NE';
                j.Location_Type__c = 'Hybrid';
                j.Application_Date__c = Date.today().addDays(-40);
                j.Follow_Up_Date__c = Date.today().addDays(-25);
                j.Rating_Scale__c = '3';
            } else {
                j.Job_Type__c = 'Contract';
                j.Salary__c = 3000;
                j.Salary_Type__c = 'Weekly';
                j.Location__c = 'Houston, TX';
                j.Location_Type__c = 'Remote';
                j.Application_Date__c = Date.today().addDays(-60);
                j.Follow_Up_Date__c = Date.today().addDays(-45);
                j.Rating_Scale__c = '5';
            }
            jobApps.add(j);
        }
        Database.insert(jobApps, AccessLevel.SYSTEM_MODE);

        for (Job_Application__c jobApp : jobApps) {
            if (jobApp.Application_Date__c == Date.today()) {
                Test.setCreatedDate(jobApp.Id, Date.today().addDays(-35));
            } else if (jobApp.Application_Date__c == Date.today().addDays(-40)) {
                Test.setCreatedDate(jobApp.Id, Date.today().addDays(-45));
            } else if (jobApp.Application_Date__c == Date.today().addDays(-60)) {
                Test.setCreatedDate(jobApp.Id, Date.today().addDays(-70));
            } else {
                Test.setCreatedDate(jobApp.Id, Date.today());
            }
        }

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