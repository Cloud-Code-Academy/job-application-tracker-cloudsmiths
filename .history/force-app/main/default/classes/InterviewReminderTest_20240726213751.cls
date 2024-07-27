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
            j.Status__c = 'Saved';
            j.Company__c = accounts[i].Id;
            j.Primary_Contact__c = contacts[i].Id;
            j.Position_Title__c = 'Developer' + i + 'at' + accounts[i].Name;
            if (i < 100) {
                j.Job_Type__c;
                j.Description__c;
                j.Salary__c;
                
            } else if (i < 200) {

            } else {

            }
            jobApps.add(j);
        }
        Database.insert(jobApps, AccessLevel.SYSTEM_MODE);
    }

}