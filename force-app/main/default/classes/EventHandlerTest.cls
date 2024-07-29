@IsTest
public with sharing class EventHandlerTest extends TriggerHandler{
    @TestSetup
    static void createTestData(){

        Test.startTest();
        createUsers();
        Test.stopTest();
        //Create accounts
        List<User> userList = [SELECT Id, Name FROM User WHERE Username LIKE '%@ccacapstone.com'];
        List<Account> newAccounts = new List<Account>();
        for(Integer i = 0; i < 3; i++){
            Account newacc = new Account(Name = ' Test Company ' + i,OwnerId = userList[0].Id);
            newAccounts.add(newacc);
        }
        insert newAccounts;
        
        
        List<Account> accList = [SELECT Id, Name FROM Account];
        List<Job_Application__c> newJobAppList = new List<Job_Application__c>();
        for(Integer i = 0; i < userList.size(); i++){
            for(Integer j = 0; j < accList.size(); j++){
            Job_Application__c jobApp = new Job_Application__c();
            jobApp.OwnerId = userList[i].Id;
            jobApp.Company__c = accList[j].Id;
            jobApp.Status__c = 'Saved';
            newJobAppList.add(jobApp);
            }
        }

        Database.insert(newJobAppList,System.AccessLevel.SYSTEM_MODE);
        

        List<Job_Application__c> jobApps = [SELECT Id, Company__c, OwnerId FROM Job_Application__c];
        List<Event> newEvents = new List<Event>();
        List<Datetime> dateTimeList = new List<Datetime>();
        dateTimeList.add(Datetime.newInstance(2024,7,23,10,0,0));
        dateTimeList.add(Datetime.newInstance(2024,7,24,14,0,0));
        dateTimeList.add(Datetime.newInstance(2024,7,25,15,0,0));

        for(Integer i = 0; i < jobApps.size(); i++){
            Event e = new Event();
            e.WhatId = jobApps[i].Id;
            e.OwnerId = jobApps[i].OwnerId;
            for(Integer j = 0; j < dateTimeList.size(); j++){
                e.StartDateTime = dateTimeList[j];
                e.EndDateTime = dateTimeList[j].addHours(1);
            }
            e.Subject = 'Interview';
            newEvents.add(e);
        }

        Database.insert(newEvents, AccessLevel.SYSTEM_MODE);
    }

    @IsTest
    static void testEventValidationOverLappingEvents(){

        List<Job_Application__c> jobApps = [SELECT Id, Company__c, OwnerId FROM Job_Application__c];
        List<Id> jobAppIds = new List<Id>();
        for(Job_Application__c jobApp :jobApps){
            jobAppIds.add(jobApp.Id);
        }
        List<Event> updatedEvents = new List<Event>();
        List<Event> existingEvents = [SELECT Id, Subject, WhatId, StartDateTime, EndDateTime, OwnerId FROM Event WHERE WhatId IN :jobAppIds];
        for(Event e :existingEvents){
            Event ev = new Event();
            ev.Subject = e.Subject;
            ev.WhatId = e.WhatId;
            ev.StartDateTime = e.StartDateTime.addMinutes(30);
            ev.EndDateTime = e.EndDateTime.addMinutes(30);
            ev.OwnerId = e.OwnerId;
            updatedEvents.add(ev);
        }
        Integer eventCount = existingEvents.size();
        
        Test.startTest();
        try{
            insert updatedEvents;
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('Please select a new time.'),'Event inserted');
        }
            
        Test.stopTest();
        
        List<Event> confirmEventCountList = [SELECT Id, Subject, WhatId, StartDateTime, EndDateTime, OwnerId FROM Event WHERE WhatId IN :jobAppIds];
        System.assertEquals(eventCount, confirmEventCountList.size(), 'Event Count is Incorrect');

    }

    @IsTest
    static void testEventValidationNonOverLappingEvents(){

        List<Job_Application__c> jobApps = [SELECT Id, Company__c, OwnerId FROM Job_Application__c];
        List<Id> jobAppIds = new List<Id>();
        for(Job_Application__c jobApp :jobApps){
            jobAppIds.add(jobApp.Id);
        }
        List<Event> updatedEvents = new List<Event>();
        List<Event> existingEvents = [SELECT Id, Subject, WhatId, StartDateTime, EndDateTime, OwnerId FROM Event WHERE WhatId IN :jobAppIds];
        for(Event e :existingEvents){
            Event ev = new Event();
            ev.Subject = e.Subject;
            ev.WhatId = e.WhatId;
            ev.StartDateTime = e.StartDateTime.addHours(3);
            ev.EndDateTime = e.EndDateTime.addHours(3);
            ev.OwnerId = e.OwnerId;
            updatedEvents.add(ev);
        }
        Integer eventCount = existingEvents.size();
        
        Test.startTest();
        insert updatedEvents;
        Test.stopTest();
        
        List<Event> confirmEventCountList = [SELECT Id, Subject, WhatId, StartDateTime, EndDateTime, OwnerId FROM Event WHERE WhatId IN :jobAppIds];
        System.assertEquals(eventCount * 2, confirmEventCountList.size(), 'Event Count is Incorrect');

    }

    @IsTest
    static void testEventValidationWeekends(){

        List<Job_Application__c> jobApps = [SELECT Id, Company__c, OwnerId FROM Job_Application__c];
        List<Id> jobAppIds = new List<Id>();
        for(Job_Application__c jobApp :jobApps){
            jobAppIds.add(jobApp.Id);
        }
        List<Event> newEvents = new List<Event>();
        List<Datetime> dateTimeList = new List<Datetime>();
        dateTimeList.add(Datetime.newInstance(2024,7,27,10,0,0));
        dateTimeList.add(Datetime.newInstance(2024,7,28,14,0,0));
        dateTimeList.add(Datetime.newInstance(2024,8,4,15,0,0));

        for(Integer i = 0; i < jobApps.size(); i++){
            Event e = new Event();
            e.WhatId = jobApps[i].Id;
            e.OwnerId = jobApps[i].OwnerId;
            for(Integer j = 0; j < dateTimeList.size(); j++){
                e.StartDateTime = dateTimeList[j];
                e.EndDateTime = dateTimeList[j].addHours(1);
            }
            e.Subject = 'Interview';
            newEvents.add(e);
        }

        Integer eventCount = newEvents.size();
        
        Test.startTest();
        try{
            insert newEvents;
        }
        catch (Exception e){
            System.assert(e.getMessage().contains('Event cannot be scheduled on a weekend.'),'Event inserted');
        }
            
        Test.stopTest();
        
        List<Event> confirmEventCountList = [SELECT Id, Subject, WhatId, StartDateTime, EndDateTime, OwnerId FROM Event WHERE WhatId IN :jobAppIds];
        System.assertEquals(eventCount, confirmEventCountList.size(), 'Event Count is Incorrect');

    }


    @future
    static void createUsers(){
        List<User> userList = new List<User>();
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE UserLicense.Name = 'Salesforce' LIMIT 1];
        UserRole role = [SELECT Id, Name FROM UserRole WHERE Name = 'Customer Support, North America'];
        for(Integer i = 0; i < 3; i++){
            User newUser = new User();
            newUser.LastName = 'TestLastName' + i;
            newUser.FirstName = 'TestFirstName' + i;
            newUser.Email = 'Tester' + i + '@ccacapstone.com';
            newUser.Username = 'Tester' + i + '@ccacapstone.com';
            newUser.Alias = 'Tester' + i;
            newUser.TimeZoneSidKey = 'America/Los_Angeles';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.LocaleSidKey = 'en_US';
            newUser.ProfileId = userProfile.Id;
            newUser.UserRoleId = role.Id;
            newUser.IsActive = true;
            userList.add(newUser);
        }
        insert userList;

        PermissionSet permSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Job_Application_Permission_Set'];
        List<User> insertedUserList = [SELECT Id, Name FROM User WHERE Username LIKE '%@ccacapstone.com'];
        List<PermissionSetAssignment> permSetList = new List<PermissionSetAssignment>();
        for(User eachUser :insertedUserList){
            PermissionSetAssignment permAssignment = new PermissionSetAssignment();
            permAssignment.AssigneeId = eachUser.Id;
            permAssignment.PermissionSetId = permSet.Id;
            permSetList.add(permAssignment);
        }
        insert permSetList;
    }
}