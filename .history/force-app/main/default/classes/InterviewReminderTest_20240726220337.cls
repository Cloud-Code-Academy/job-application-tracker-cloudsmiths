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
        List<User> users = new List<User>();
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        List<Event> interviews = new List<Events>();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        for (Integer i = 0; i < numRecords; i++) {
            User u = new User();
            u.Alias = 'user' + i;
            u.Email='testemail' + i + '@cloudsmiths.com';
            u.EmailEncodingKey='UTF-8';
            u.FirstName='Test' + i;
            u.LastName='User' + i;
            u.LanguageLocaleKey='en_US'; 
            u.LocaleSidKey='en_US';
            u.ProfileId = p.Id; 
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName='testemail' + i + '@cloudsmiths.com';
            users.add(u);
        }
        Database.insert(users, AccessLevel.SYSTEM_MODE);

        // Create Permission Set Assignment Here

        for (Integer i = 0; i < numRecords; i++) {
            Account a = new Account();
            a.Name = 'Test Account ' + i;
            accounts.add(a);
        }
        Database.insert(accounts, AccessLevel.SYSTEM_MODE);


        for (Integer i = 0; i < numRecords; i++) {
            Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'Contact ' + i;
            c.AccountId = accounts[i].Id;
            c.Email = 'testcontact' + i + '@cloudsmiths.com';
            contacts.add(c);
        }
        Database.insert(contacts, AccessLevel.SYSTEM_MODE);


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
                j.Rating_Scale__c = 2;
            } else if (i < 200) {
                j.Job_Type__c = 'Part-time';
                j.Salary__c = 58;
                j.Salary_Type__c = 'Hourly';
                j.Location__c = 'Omaha, NE';
                j.Location_Type__c = 'Hybrid';
                j.Application_Date__c = Date.today().addDays(-40);
                j.Follow_Up_Date__c = Date.today().addDays(-25);
                j.Rating_Scale__c = 3;
            } else {
                j.Job_Type__c = 'Contract';
                j.Salary__c = 3000;
                j.Salary_Type__c = 'Weekly';
                j.Location__c = 'Houston, TX';
                j.Location_Type__c = 'Remote';
                j.Application_Date__c = Date.today().addDays(-60);
                j.Follow_Up_Date__c = Date.today().addDays(-45);
                j.Rating_Scale__c = 5;
            }
            jobApps.add(j);
        }
        Database.insert(jobApps, AccessLevel.SYSTEM_MODE);

        for (Job_Application__c jobApp : jobApps) {
            if (jobApp.Application_Date__c = Date.today()) {
                Test.setCreatedDate(jobApp.Id, Date.today().addDays(-35));
            } else if (jobApp.Application_Date__c = Date.today().addDays(-40)) {
                Test.setCreatedDate(jobApp.Id, Date.today().addDays(-45));
            } else if (jobApp.Application_Date__c = Date.today().addDays(-60)) {
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
            e.Type = 'Interview';
            e.StartDateTime = DateTime.now().addDays(10);
        }
    }

}