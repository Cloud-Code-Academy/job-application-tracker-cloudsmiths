@IsTest
public with sharing class JobApplicationHandlerTest {
    @TestSetup
    static void createData(){
        List<Account> newAccounts = new List<Account>();
        for(Integer i = 0; i < 20; i++){
            Account acc = new Account(Name = 'Test Account ' + i);
            newAccounts.add(acc);
        }

        insert newAccounts;

        List<Account> insertedAccounts = [SELECT Id, Name FROM Account];
        List<Contact> newContacts = new List<Contact>();
        for(Integer i = 0; i< insertedAccounts.size(); i++){
            if(Math.mod(i, 3) == 0){
                Contact con = new Contact(FirstName = 'Test', LastName = 'Contact ' + i,Email = 'tester' + i + '@gmail.com', AccountId = insertedAccounts[i].Id);
                newContacts.add(con);
                Contact con2 = new Contact(FirstName = 'Test ' + i, LastName = 'Contact ' + i,Email = 'testing' + i + '@gmail.com', AccountId = insertedAccounts[i].Id);
                newContacts.add(con2);
            }
            if(Math.mod(i,4) == 0){
                Contact con = new Contact(FirstName = 'Test', LastName = 'Contact ' + i,Email = 'tester' + i + '@gmail.com', AccountId = insertedAccounts[i].Id);
                newContacts.add(con);
                Contact con2 = new Contact(FirstName = 'Test ' + i, LastName = 'Contact ' + i,Email = 'testing' + i + '@gmail.com', AccountId = insertedAccounts[i].Id);
                newContacts.add(con2);
                Contact con3 = new Contact(FirstName = 'Test ' + i, LastName = 'Contact',Email = 'testperson' + i + '@gmail.com', AccountId = insertedAccounts[i].Id);
                newContacts.add(con3);
            }
            if(Math.mod(i,5) == 0){
                continue;
            }
            else{
                Contact con = new Contact(FirstName = 'Test', LastName = 'Contact ' + i,Email = 'tester' + i + '@gmail.com', AccountId = insertedAccounts[i].Id);
                newContacts.add(con);
            }
        }
        insert newContacts;

    }

    @IsTest
    static void testSetPrimaryContact(){
        List<Account> accountList = [SELECT Id, Name FROM Account];
        List<Job_Application__c> newJobApps = new List<Job_Application__c>();
        for(Account acc :accountList){
            Job_Application__c jobApp = new Job_Application__c(Company__c = acc.Id, Status__c = 'Saved');
            newJobApps.add(jobApp);
        }

        Test.startTest();
        insert newJobApps;
        Test.stopTest();

        List<Job_Application__c> appVerificationList = [SELECT Id, Company__c,Primary_Contact__c FROM Job_Application__c];
        List<Id> accountIdList = new List<Id>();
        for(Account acc :accountList){
            accountIdList.add(acc.Id);
        }
        List<Contact> contactList = [SELECT Id, AccountId, CreatedDate FROM Contact WHERE Id IN :accountIdList Order By CreatedDate ASC];
        Map<Id,Id> accountIdByJobAppIdMap = new Map<Id,Id>();
        Map<Id,Id> contactIdByAccountIdMap = new Map<Id,Id>();
        Map<Id,Id> contactIdByJobAppIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :appVerificationList){
            accountIdByJobAppIdMap.put(jobApp.Id, jobApp.Company__c);
        }
        for(Contact con :contactList){
            if(!contactIdByAccountIdMap.containsKey(con.AccountId)){
                contactIdByAccountIdMap.put(con.AccountId, con.Id);
            }
        }
        for(Job_Application__c jobApp :appVerificationList){
            if(contactIdByAccountIdMap.containsKey(jobApp.Company__c)){
                contactIdByJobAppIdMap.put(jobApp.Id, contactIdByAccountIdMap.get(jobApp.Company__c));
            }
        }

        for(Job_Application__c jobApp :appVerificationList){
            if(contactIdByJobAppIdMap.containsKey(jobApp.Id)){
                System.assertEquals(contactIdByJobAppIdMap.get(jobApp.Id), jobApp.Primary_Contact__c, 'Primary Contact Set Incorrectly');
            }
        }
    }

    @IsTest
    static void testCreateMissingHiringTeam(){
        List<Account> accountList = [SELECT Id, Name FROM Account];
        List<Job_Application__c> newJobApps = new List<Job_Application__c>();
        for(Account acc :accountList){
            Job_Application__c jobApp = new Job_Application__c(Company__c = acc.Id, Status__c = 'Saved');
            newJobApps.add(jobApp);
        }
        
        
        

        Test.startTest();
        insert newJobApps;
        Test.stopTest();

        List<Job_Application__c> appverifyList = [SELECT Id, Primary_Contact__c FROM Job_Application__c];
        List<Hiring_Team__c> hiringTeamList = [SELECT Id, Name, Job_Application__c, Contact__c, Primary_Contact__c FROM Hiring_Team__c];
        Map<Id,Hiring_Team__c> hiringTeamByContactIdMap = new Map<Id,Hiring_Team__c>();
        
        for(Hiring_Team__c teamMember :hiringTeamList){
            hiringTeamByContactIdMap.put(teamMember.Contact__c,teamMember);
        }

        for(Job_Application__c jobApp :appverifyList){
            if(hiringTeamByContactIdMap.containsKey(jobApp.Primary_Contact__c)){
                System.assertEquals(true, hiringTeamByContactIdMap.get(jobApp.Primary_Contact__c).Primary_Contact__c, 'Hiring Team Created Incorrectly');
            }
        }
    }

    @IsTest
    static void testTaxWithholdingCalculator(){
        //Create 84 accounts
        //Create Job App for each account. One app for each filing status, tax bracket, and deduction type
        //run code
        //Verify yearly and monthly calculations are correct

    }

    @IsTest
    static void testdeductionUpdatesAndValidation(){
        //Create 9 accounts
        /**
         * Create Job Apps for each account under below conditions:
         * Standard Deduction with Itemized Populated
         * Standard Deduction with Standard Populated
         * Itemized with Standard Populated
         * Itemized with Itemized Populated
         * Deduction null with deductions null
         * Deduction None with Standard populated
         * Deduction None with Itemized populated
         * Itemized with null itemized amount
         **/
        //Run code for all except error
        //validate
        //run code for error
        //validate
    }
}