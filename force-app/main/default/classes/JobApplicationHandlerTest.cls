/**
 * @description       : Test class for JobApplicationHandler
 * @author            : Tyler Riden
 * @group             : Cloud Smiths
 * @last modified on  : 08-01-2024
 * @last modified by  : Tyler Riden
**/
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
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        Job_Application__c newJobApp1 = new Job_Application__c (Salary__c = 10000, Salary_Type__c = 'Annual', Tax_Filing_Status__c = 'Single', Deduction_Type__c = 'None');
        jobAppList.add(newJobApp1);
        Job_Application__c newJobApp2 = new Job_Application__c (Salary__c = 50, Salary_Type__c = 'Hourly', Tax_Filing_Status__c = 'Single', Deduction_Type__c = 'Standard Deduction');
        jobAppList.add(newJobApp2);
        Job_Application__c newJobApp3 = new Job_Application__c (Salary__c = 190000, Salary_Type__c = 'Annual', Tax_Filing_Status__c = 'Single', Deduction_Type__c = 'Itemized Deduction', Itemized_Deduction_Amount__c = 50000);
        jobAppList.add(newJobApp3);
        Job_Application__c newJobApp4 = new Job_Application__c (Salary__c = 1500, Salary_Type__c = 'Weekly', Tax_Filing_Status__c = 'Married, filing jointly', Deduction_Type__c = 'None');
        jobAppList.add(newJobApp4);
        Job_Application__c newJobApp5 = new Job_Application__c (Salary__c = 85, Salary_Type__c = 'Hourly', Tax_Filing_Status__c = 'Married, filing jointly', Deduction_Type__c = 'Itemized Deduction', Itemized_Deduction_Amount__c = 10000);
        jobAppList.add(newJobApp5);
        Job_Application__c newJobApp6 = new Job_Application__c (Salary__c = 800000, Salary_Type__c = 'Annual', Tax_Filing_Status__c = 'Married, filing jointly', Deduction_Type__c = 'Standard Deduction');
        jobAppList.add(newJobApp6);
        Job_Application__c newJobApp7 = new Job_Application__c (Salary__c = 45000, Salary_Type__c = 'Annual', Tax_Filing_Status__c = 'Married, filing jointly', Deduction_Type__c = 'None');
        jobAppList.add(newJobApp7);
        Job_Application__c newJobApp8 = new Job_Application__c (Salary__c = 3600, Salary_Type__c = 'Weekly', Tax_Filing_Status__c = 'Married, filing separately', Deduction_Type__c = 'None');
        jobAppList.add(newJobApp8);
        Job_Application__c newJobApp9 = new Job_Application__c (Salary__c = 80, Salary_Type__c = 'Hourly', Tax_Filing_Status__c = 'Married, filing separately', Deduction_Type__c = 'Itemized Deduction', Itemized_Deduction_Amount__c = 20000);
        jobAppList.add(newJobApp9);
        Job_Application__c newJobApp10 = new Job_Application__c (Salary__c = 95000, Salary_Type__c = 'Annual', Tax_Filing_Status__c = 'Head of Household', Deduction_Type__c = 'None');
        jobAppList.add(newJobApp10);
        Job_Application__c newJobApp11 = new Job_Application__c (Salary__c = 1000, Salary_Type__c = 'Weekly', Tax_Filing_Status__c = 'Head of Household', Deduction_Type__c = 'Standard Deduction');
        jobAppList.add(newJobApp11);
        Job_Application__c newJobApp12 = new Job_Application__c (Salary__c = 100, Salary_Type__c = 'Hourly', Tax_Filing_Status__c = 'Head of Household', Deduction_Type__c = 'Itemized Deduction', Itemized_Deduction_Amount__c = 30000);
        jobAppList.add(newJobApp12);
        Job_Application__c newJobApp13 = new Job_Application__c (Salary__c = 150000, Salary_Type__c = 'Annual', Tax_Filing_Status__c = null);
        jobAppList.add(newJobApp13);
        
        Test.startTest();
        insert jobAppList;
        Test.stopTest();

        List<Job_Application__c> jobAppVerificationList = [SELECT Id, Salary__c, Salary_Type__c, Tax_Filing_Status__c, Deduction_Type__c, Standard_Deduction__c, Itemized_Deduction_Amount__c, Take_Home_Amount__c, Federal_Income_Tax_Withheld__c, Social_Security_Withheld__c, Medicare_Withheld__c,Monthly_Take_Home_Amount__c, Monthly_Federal_Income_Tax_Withheld__c, Monthly_Social_Security_Withheld__c, Monthly_Medicare_Withheld__c
                                                            FROM Job_Application__c
                                                            WHERE Company__c = null];

        for(Job_Application__c jobApp :jobAppVerificationList){
            Decimal acceptableRange = 1.5;
            if(jobApp.Salary__c == 10000 && jobApp.Salary_Type__c == 'Annual' && jobApp.Tax_Filing_Status__c == 'Single'){
                Decimal fedIncomeTax = 1000;
                Decimal medicare = 145;
                Decimal socialSecurity = 620;
                Decimal takeHome = 8235;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 50 && jobApp.Salary_Type__c == 'Hourly' && jobApp.Tax_Filing_Status__c == 'Single'){
                Decimal fedIncomeTax = 15140.38;
                Decimal medicare = 1307.18;
                Decimal socialSecurity = 5589.30;
                Decimal takeHome = 81963.14;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 190000 && jobApp.Salary_Type__c == 'Annual' && jobApp.Tax_Filing_Status__c == 'Single'){
                Decimal fedIncomeTax = 26999.86;
                Decimal medicare = 2030;
                Decimal socialSecurity = 8680;
                Decimal takeHome = 152290.14;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 1500 && jobApp.Salary_Type__c == 'Weekly' && jobApp.Tax_Filing_Status__c == 'Married, filing jointly'){
                Decimal fedIncomeTax = 8920;
                Decimal medicare = 1131;
                Decimal socialSecurity = 4836;
                Decimal takeHome = 63113;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 85 && jobApp.Salary_Type__c == 'Hourly' && jobApp.Tax_Filing_Status__c == 'Married, filing jointly'){
                Decimal fedIncomeTax = 27310.88;
                Decimal medicare = 2418.60;
                Decimal socialSecurity = 9932.40;
                Decimal takeHome = 137138.12;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 800000 && jobApp.Salary_Type__c == 'Annual' && jobApp.Tax_Filing_Status__c == 'Married, filing jointly'){
                Decimal fedIncomeTax = 215664.73;
                Decimal medicare = 11198.35;
                Decimal socialSecurity = 9932.40;
                Decimal takeHome = 563204.52;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 3600 && jobApp.Salary_Type__c == 'Weekly' && jobApp.Tax_Filing_Status__c == 'Married, filing separately'){
                Decimal fedIncomeTax = 38735.78;
                Decimal medicare = 2714.40;
                Decimal socialSecurity = 9932.40;
                Decimal takeHome = 135817.42;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 80 && jobApp.Salary_Type__c == 'Hourly' && jobApp.Tax_Filing_Status__c == 'Married, filing separately'){
                Decimal fedIncomeTax = 28535.86;
                Decimal medicare = 2122.80;
                Decimal socialSecurity = 9076.80;
                Decimal takeHome = 126664.54;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 95000 && jobApp.Salary_Type__c == 'Annual' && jobApp.Tax_Filing_Status__c == 'Head of Household'){
                Decimal fedIncomeTax = 14600.88;
                Decimal medicare = 1377.50;
                Decimal socialSecurity = 5890;
                Decimal takeHome = 73131.62;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 1000 && jobApp.Salary_Type__c == 'Weekly' && jobApp.Tax_Filing_Status__c == 'Head of Household'){
                Decimal fedIncomeTax = 3429.98;
                Decimal medicare = 452.40;
                Decimal socialSecurity = 1934.40;
                Decimal takeHome = 46183.22;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 100 && jobApp.Salary_Type__c == 'Hourly' && jobApp.Tax_Filing_Status__c == 'Head of Household'){
                Decimal fedIncomeTax = 34513.86;
                Decimal medicare = 2581;
                Decimal socialSecurity = 9932.40;
                Decimal takeHome = 160972.74;
                System.assert(jobApp.Federal_Income_Tax_Withheld__c >= fedIncomeTax - acceptableRange && jobApp.Federal_Income_Tax_Withheld__c <= fedIncomeTax + acceptableRange, 'Federal Income Tax Incorrect');
                System.assert(jobApp.Social_Security_Withheld__c >= socialSecurity - acceptableRange && jobApp.Social_Security_Withheld__c <= socialSecurity + acceptableRange, 'Social Security Incorrect');
                System.assert(jobApp.Medicare_Withheld__c >= medicare - acceptableRange && jobApp.Medicare_Withheld__c <= medicare + acceptableRange, 'Medicare Incorrect');
                System.assert(jobApp.Take_Home_Amount__c >= takeHome - acceptableRange && jobApp.Take_Home_Amount__c <= takeHome + acceptableRange, 'Take-Home Incorrect');
            }
            if(jobApp.Salary__c == 150000 && jobApp.Salary_Type__c == 'Annual' && jobApp.Tax_Filing_Status__c == null){
                System.assertEquals(0, jobApp.Take_Home_Amount__c, 'Take-Home Pay Should be 0');
                System.assertEquals(0, jobApp.Federal_Income_Tax_Withheld__c, 'Federal Income Tax Should be 0');
                System.assertEquals(0, jobApp.Social_Security_Withheld__c, 'Social Security Should be 0');
                System.assertEquals(0, jobApp.Medicare_Withheld__c, 'Medicare Should be 0');
            }
        }
    }

    @IsTest
    static void testdeductionUpdates(){
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        Job_Application__c newJobApp1 = new Job_Application__c(Deduction_Type__c = 'Standard Deduction', Itemized_Deduction_Amount__c = 10000);
        jobAppList.add(newJobApp1);
        Job_Application__c newJobApp2 = new Job_Application__c(Deduction_Type__c = 'Itemized Deduction', Standard_Deduction__c = 10000, Itemized_Deduction_Amount__c = 5000);
        jobAppList.add(newJobApp2);
        Job_Application__c newJobApp3 = new Job_Application__c(Deduction_Type__c = 'None', Itemized_Deduction_Amount__c = 10000, Standard_Deduction__c = 10000);
        jobAppList.add(newJobApp3);
        Job_Application__c newJobApp4 = new Job_Application__c(Deduction_Type__c = null, Itemized_Deduction_Amount__c = 10000, Standard_Deduction__c = 10000);
        jobAppList.add(newJobApp4);

        Test.startTest();
        insert jobAppList;
        Test.stopTest();

        List<Job_Application__c> jobAppVerificationList = [SELECT Id, Deduction_Type__c, Standard_Deduction__c, Itemized_Deduction_Amount__c 
                                                            FROM Job_Application__c];
        for(Job_Application__c jobApp :jobAppVerificationList){
            if(jobApp.Deduction_Type__c == 'Standard Deduction'){
                System.assertEquals(null, jobApp.Itemized_Deduction_Amount__c,'Itemized Deduction Amount Not Null');
            }
            if(jobApp.Deduction_Type__c == 'Itemized Deduction'){
                System.assertEquals(null, jobApp.Standard_Deduction__c,'Standard Deduction Not Null');
            }
            if(jobApp.Deduction_Type__c == 'None' || jobApp.Deduction_Type__c == null){
                System.assertEquals(null, jobApp.Standard_Deduction__c, 'Standard Deduction Not Null');
                System.assertEquals(null, jobApp.Itemized_Deduction_Amount__c,'Itemized Deduction Amount Not Null');
            }
            
        }
    }

    @IsTest
    static void testValidations(){
        List<Job_Application__c> jobAppList = new List<Job_Application__c>();
        Job_Application__c newJobApp1 = new Job_Application__c(Deduction_Type__c = 'Itemized Deduction');
        jobAppList.add(newJobApp1);
        Job_Application__c newjobApp2 = new Job_Application__c(Salary__c = -50000);
        jobAppList.add(newjobApp2);
        
        try{
            insert newJobApp1;
        } catch (Exception e){
            System.assert(e.getMessage().contains('If Itemized Deduction is selected, the Itemized Deduction Amount must be provided'),'Incorrect Error Message' );
        }

        try{
            insert newjobApp2;
        } catch(Exception e){
            System.assert(e.getMessage().contains('You cannot enter a negative salary'),'Incorrect Error Message' );
        }
    }
}