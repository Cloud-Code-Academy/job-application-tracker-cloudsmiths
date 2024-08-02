/**
 * @description       : Tests for the InterviewReminder Class
 * @author            : Riley Meyer
 * @group             : Cloud Smiths
 * @last modified on  : 08-02-2024
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
    }

    @IsTest
    static void sendEmailReminerTest(){
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW
                                            WITH SYSTEM_MODE];

        Test.startTest();
        InterviewReminder.sendEmailReminder();
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assert(invocations > 0, 'No emails were sent');
    }

    @IsTest
    static void getScheduledInterviewsTest(){
        String myUserId = UserInfo.getUserId();
        User userOne = [SELECT Id FROM User WHERE Id = :myUserId WITH SYSTEM_MODE LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account 1' WITH SYSTEM_MODE LIMIT 1];
        Contact con = [SELECT Id, LastName FROM Contact WHERE LastName = 'Contact 1' WITH SYSTEM_MODE LIMIT 1];

        Event notJA = new Event();
        notJA.ownerId = userOne.Id;
        notJA.Location = 'Not a Job Application';
        notJA.Subject = 'Interview';
        notJA.WhoId = con.Id;
        notJA.WhatId = acc.Id;
        notJA.Interview_Type__c = 'Screening Interview';
        notJA.Interview_Format__c = 'Phone';
        notJA.StartDateTime = System.now().addDays(1);
        notJA.EndDateTime = notJA.StartDateTime.addHours(1);
        String eventStartDay = notJA.StartDateTime.format('EEEE');
        String eventEndDay = notJA.EndDateTime.format('EEEE');
        if(eventStartDay == 'Saturday' || eventEndDay == 'Saturday'){
            notJA.StartDateTime = notJA.StartDateTime.addDays(2);
            notJA.EndDateTime = notJA.EndDateTime.addDays(2);
        } else if(eventStartDay == 'Sunday' || eventEndDay == 'Sunday'){
            notJA.StartDateTime = notJA.StartDateTime.addDays(1);
            notJA.EndDateTime = notJA.EndDateTime.addDays(1);
        }
        Database.insert(notJA, AccessLevel.SYSTEM_MODE);

        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW
                                            WITH SYSTEM_MODE];

        Test.startTest();
        List<Event> interviews = InterviewReminder.getScheduledInterviews();
        Test.stopTest();

        System.assertEquals(scheduledInterviews.size() - 1, interviews.size(), 'Get Scheduled Interviews did not return all interviews');
        System.assertEquals(false, interviews.contains(notJA), 'Get Scheduled Interviews returned an interview not related to a Job Application');
    }

    @IsTest
    static void getJobApplicationRecordsTest(){
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW
                                            WITH SYSTEM_MODE];
        Test.startTest();
        Map<Id, Job_Application__c> jobIdToJobApp = InterviewReminder.getJobApplicationRecords(scheduledInterviews);
        Test.stopTest();

        System.assertEquals(scheduledInterviews.size(), jobIdToJobApp.size(), 'Get Job Application Records did not return all Job Applications');
        for (Event interview : scheduledInterviews) {
            System.assertEquals(true, jobIdToJobApp.containsKey(interview.WhatId), 'Get Job Application Records did not return all Job Applications');
        }
    }

    @IsTest
    static void getEmailAddressesTest(){
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW
                                            WITH SYSTEM_MODE];

        Set<Id> userIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            userIds.add(interview.OwnerId);
        }

        Test.startTest();
        Map<Id, User> idToUser = InterviewReminder.getEmailAddresses(scheduledInterviews);
        Test.stopTest();

        System.assertEquals(userIds.size(), idToUser.size(), 'Get Email Addresses did not return all Users');
        for (Event interview : scheduledInterviews) {
            System.assertEquals(true, idToUser.containsKey(interview.OwnerId), 'Get Email Addresses did not return all Users');
        }
    }

    @IsTest
    static void getContactRecordsTest(){
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW
                                            WITH SYSTEM_MODE];

        Set<Id> jobAppIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            jobAppIds.add(interview.WhatId);
        }

        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c, Primary_Contact__c, Location__c, Location_Type__c, Job_Type__c, Salary__c, Salary_Type__c, Job_Posting_URL__c, Rating_Scale__c
                                                        FROM Job_Application__c
                                                        WHERE Id IN :jobAppIds
                                                        WITH SYSTEM_MODE]);

        Test.startTest();
        Map<Id, Contact> idToContact = InterviewReminder.getContactRecords(scheduledInterviews, jobIdToJobApp);
        Test.stopTest();

        for (Job_Application__c jobApp : jobIdToJobApp.values()) {
            System.assertEquals(true, idToContact.containsKey(jobApp.Primary_Contact__c), 'Get Contact Records did not find all Accounts');
        }
    }

    @IsTest
    static void getAccountRecordsTest(){
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW
                                            WITH SYSTEM_MODE];

        Set<Id> jobAppIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            jobAppIds.add(interview.WhatId);
        }

        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c, Primary_Contact__c, Location__c, Location_Type__c, Job_Type__c, Salary__c, Salary_Type__c, Job_Posting_URL__c, Rating_Scale__c
                                                        FROM Job_Application__c
                                                        WHERE Id IN :jobAppIds
                                                        WITH SYSTEM_MODE]);
        Test.startTest();
        Map<Id, Account> idToAccount = InterviewReminder.getAccountRecords(jobIdToJobApp);
        Test.stopTest();

        for (Job_Application__c jobApp : jobIdToJobApp.values()) {
            System.assertEquals(true, idToAccount.containsKey(jobApp.Company__c), 'Get Account Records did not find all Accounts');
        }
    }

    @IsTest
    static void schedulableTest(){
        Test.startTest();
        InterviewReminder reminder = new InterviewReminder();
        String cron = '0 0 0 15 3 ? 2025';
        String jobId = System.schedule('Interview Reminder', cron, reminder);
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cron, ct.CronExpression, 'CronExpression does not match');
        System.assertEquals(0, ct.TimesTriggered, 'TimesTriggered does not match');
        System.assertEquals('2025-03-15 00:00:00', String.valueOf(ct.NextFireTime), 'NextFireTime does not match');
    }
}