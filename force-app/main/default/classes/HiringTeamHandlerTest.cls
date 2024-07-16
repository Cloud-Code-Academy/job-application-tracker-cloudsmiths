@IsTest
public with sharing class HiringTeamHandlerTest {
    @TestSetup
    static void createData(){
        List<Account> newAccounts = new List<Account>();
        for(Integer i = 0; i < 10; i++){
           Account newAcc = new Account (Name = 'Test Account ' + i);
           newAccounts.add(newAcc);
        }
        insert newAccounts;

        List<Account> insertedAccounts = [SELECT Id, Name FROM Account];
        List<Contact> newContacts = new List<Contact>();
        List<Job_Application__c> newJobApps = new List<Job_Application__c>();
        for(Account acc :insertedAccounts){
            Contact newCon = new Contact (FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
            newContacts.add(newCon);

            Job_Application__c newApp = new Job_Application__c (Company__c = acc.Id, Status__c = 'Saved');
            newJobApps.add(newApp);
        }
        insert newContacts;
        insert newJobApps;
    }

    @IsTest
    static void testSetPrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = true);
            hiringTeamList.add(newTeam);
        }
        insert hiringTeamList;

        Test.startTest();
        HiringTeamHandler.setApplicationPrimaryContact(hiringTeamList);
        Test.stopTest();

        List<Hiring_Team__c> verificationTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :verificationTeamList){
            System.assertEquals(true, teamMember.Primary_Contact__c, 'Primary Contact Set Incorrectly');
        }
    }

    @IsTest
    static void testSetNoPrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = false);
            hiringTeamList.add(newTeam);
        }
        insert hiringTeamList;

        Test.startTest();
        HiringTeamHandler.setApplicationPrimaryContact(hiringTeamList);
        Test.stopTest();

        List<Hiring_Team__c> verificationTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :verificationTeamList){
            System.assertEquals(false, teamMember.Primary_Contact__c, 'Primary Contact Set Incorrectly');
        }
    }

    @IsTest
    static void testAfterInsertwithPrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = true);
            hiringTeamList.add(newTeam);
        }
        

        Test.startTest();
        insert hiringTeamList;
        Test.stopTest();

        List<Hiring_Team__c> verificationTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :verificationTeamList){
            System.assertEquals(true, teamMember.Primary_Contact__c, 'Primary Contact Set Incorrectly');
        }
    }

    @IsTest
    static void testAfterInsertNoPrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = false);
            hiringTeamList.add(newTeam);
        }
        

        Test.startTest();
        insert hiringTeamList;
        Test.stopTest();

        List<Hiring_Team__c> verificationTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :verificationTeamList){
            System.assertEquals(false, teamMember.Primary_Contact__c, 'Primary Contact Set Incorrectly');
        }
    }

    @IsTest
    static void testAfterUpdatewithPrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = false);
            hiringTeamList.add(newTeam);
        }

        insert hiringTeamList;

       List<Hiring_Team__c> updatedHiringTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
       for(Hiring_Team__c teamMember :updatedHiringTeamList){
        teamMember.Primary_Contact__c = true;
       }
        
        Test.startTest();
        update updatedHiringTeamList;
        Test.stopTest();

        List<Hiring_Team__c> verificationTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :verificationTeamList){
            System.assertEquals(true, teamMember.Primary_Contact__c, 'Primary Contact Set Incorrectly');
        }
    }
    @IsTest
    static void testAfterUpdateNoPrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = true);
            hiringTeamList.add(newTeam);
        }

        List<Hiring_Team__c> updatedHiringTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
       for(Hiring_Team__c teamMember :updatedHiringTeamList){
        teamMember.Primary_Contact__c = false;
       }
        
        Test.startTest();
        update updatedHiringTeamList;
        Test.stopTest();

        List<Hiring_Team__c> verificationTeamList = [SELECT Id, Contact__c, Job_Application__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :verificationTeamList){
            System.assertEquals(false, teamMember.Primary_Contact__c, 'Primary Contact Set Incorrectly');
        }
    }

    @IsTest
    static void testRemovePrimaryContact(){
        List<Job_Application__c> jobApps = [SELECT Id, Primary_Contact__c,Company__c FROM Job_Application__c];
        List<Id> companyIds = new List<Id>();
        Map<Id,Id> jobAppIdByAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :jobApps){
            companyIds.add(jobApp.Company__c);
            jobAppIdByAccountIdMap.put(jobApp.Company__c, jobApp.Id);
        }

        List<Contact> contactList = [SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN :companyIds];
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        for(Contact con :contactList){
            Hiring_Team__c newTeam = new Hiring_Team__c (Contact__c = con.Id, Job_Application__c = jobAppIdByAccountIdMap.get(con.AccountId),Primary_Contact__c = true);
            hiringTeamList.add(newTeam);
        }

        insert hiringTeamList;

        List<Hiring_Team__c> hiringTeamUpdates = [SELECT Id, Job_Application__c, Contact__c, Primary_Contact__c FROM Hiring_Team__c];
        for(Hiring_Team__c teamMember :hiringTeamUpdates){
            teamMember.Primary_Contact__c = false;
        }

        Test.startTest();
        update hiringTeamUpdates;
        Test.stopTest();

        List<Job_Application__c> jobAppVerifyList = [SELECT Id, Primary_Contact__c FROM Job_Application__c];
        for(Job_Application__c jobApp :jobAppVerifyList){
            System.assertEquals(null, jobApp.Primary_Contact__c, 'Primary Contact Not Removed');
        }
    }

}