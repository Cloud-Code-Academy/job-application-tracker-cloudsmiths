@IsTest
public with sharing class EventHandlerTest {
    @TestSetup
    static void createTestData(){

        Test.startTest();
        List<User> userList = createUsers();
        Test.stopTest();
        //Create accounts
        List<Account> newAccounts = new List<Account>();
        for(Integer i = 0; i < 3; i++){
            Account newacc = new Account(Name = ' Test Company ' + i);
            newAccounts.add(newacc);
        }
        insert newAccounts;
        }
        //Create contacts
        
        //Create job applications
        //Create events
        
    }

    @future
    static void createUsers(){
        List<User> userList = new List<User>();
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'];
        UserRole role = [SELECT Id, Name FROM UserRole WHERE Name = 'CustomerSupportNorthAmerica'];
        for(Integer i = 0; i < 3; i++){
            User newUser = new User();
            newUser.LastName = 'TestLastName' + i;
            newUser.FirstName = 'TestLastName' + i;
            newUser.Email = 'Tester' + i + '@gmail.com';
            newUser.ProfileId = userProfile;
            newUser.UserRoleId = role;
            userList.add(newUser);
        }
        Database.insert(userList, AccessLevel.SYSTEM_MODE);
    }
}