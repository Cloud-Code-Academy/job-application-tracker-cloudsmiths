/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-27-2024
 * @last modified by  : Riley Meyer
**/
@IsTest
private class TestDataFactoryTest {
    
    @IsTest
    static void createUsersTest() {
        Integer numRecords = 400;
        Test.startTest();
        List<User> users = TestDataFactory.createUsers(numRecords);
        Test.stopTest();
    }
}