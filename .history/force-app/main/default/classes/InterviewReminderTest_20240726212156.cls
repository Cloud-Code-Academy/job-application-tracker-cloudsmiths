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
            u.Email='testemail' + i + '@test.com';
            u.EmailEncodingKey='UTF-8';
            u.FirstName='Test' + i;
            u.LastName='User' + i;
            u.LanguageLocaleKey='en_US'; 
            u.LocaleSidKey='en_US';
            u.ProfileId = p.Id; 
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName='testemail' + i + '@test.com';
        }
    }

}