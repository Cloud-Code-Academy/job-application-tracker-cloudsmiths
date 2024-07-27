/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Riley Meyer
**/
@IsTest
public class TestDataFactory {

    @TestVisible
    private static List<User> createUsers(Integer numRecords) {
        List<User> users = new List<User>();
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

        return users;
    }

    @TestVisible
    private static List<Account> createAccounts(Integer numRecords) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numRecords; i++) {
            Account a = new Account();
            a.Name = 'Test Account ' + i;
            accounts.add(a);
        }
        Database.insert(accounts, AccessLevel.SYSTEM_MODE);

        return accounts;
    }

    @TestVisible
    private static List<Contact> createContacts(List<Account> accounts, Integer numRecords) {

    }

}