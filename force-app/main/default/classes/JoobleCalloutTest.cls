/**
 * @description       : Tests for the JoobleCallout Class
 * @author            : Riley Meyer
 * @group             : Cloud Smiths
 * @last modified on  : 08-02-2024
 * @last modified by  : Riley Meyer
**/
@IsTest
private class JoobleCalloutTest {
    @IsTest
    static void getJobsFromJoobleTest(){
        // Create existing Job Application record to assert on upsert logic
        Job_Application__c existingJob = new Job_Application__c();
        existingJob.Description__c = 'DO NOT OVERWRITE THIS FIELD';
        existingJob.Jooble_Id__c = '4352497110792274330';
        Database.insert(existingJob, AccessLevel.SYSTEM_MODE);

        CreateJoobleCalloutBodyAction.FlowInput body = new CreateJoobleCalloutBodyAction.FlowInput();
        body.keywords = 'Salesforce Developer';
        body.location = 'Omaha, NE';
        body.salary = '100000';
        body.dateCreatedFrom = '2024-07-01';

        // Set the mock callout class
		Test.setMock(HttpCalloutMock.class, new JoobleCalloutMockGenerator());

        Test.startTest();
        JoobleCallout.getJobsFromJooble(body);
        Test.stopTest();

        //Query the records created by the callout mock and JoobleCalout
        List<Job_Application__c> newJobs = [SELECT Id, Salary_Type__c FROM Job_Application__c WITH SYSTEM_MODE];
        List<Job_Application__c> existingJobAfter = [SELECT Id, Salary_Type__c, Description__c 
                                                        FROM Job_Application__c
                                                        WHERE Jooble_Id__c = '4352497110792274330'
                                                        WITH SYSTEM_MODE];

        // Check that the Salary Type logic is working
        Integer annual = 0;
        Integer hourly = 0;
        Integer weekly = 0;
        for (Job_Application__c job : newJobs) {
            switch on job.Salary_Type__c {
                when 'Annual' {
                    annual++;
                }
                when 'Hourly' {
                    hourly++;
                }
                when 'Weekly' {
                    weekly++;
                }
            }
        }

        System.assertEquals(5, newJobs.size(), 'The incorrect number of jobs were created/exist');
        System.assertEquals(2, annual, 'The incorrect number of jobs were assigned the Salary Type of Annual');
        System.assertEquals(2, hourly, 'The incorrect number of jobs were assigned the Salary Type of Hourly');
        System.assertEquals(1, weekly, 'The incorrect number of jobs were assigned the Salary Type of Weekly');
        System.assertEquals(1, existingJobAfter.size(), 'Existing Job was duplicated during upsert');
        System.assertEquals('Annual', existingJobAfter[0].Salary_Type__c, 'Salary Type field was not populated on upsert');
        System.assertEquals('DO NOT OVERWRITE THIS FIELD', existingJobAfter[0].Description__c, 'Description field should not be overwritten when already populated');
    }

    @IsTest
    static void getJobsFromJoobleExceptionTest(){
        CreateJoobleCalloutBodyAction.FlowInput body = new CreateJoobleCalloutBodyAction.FlowInput();
        body.keywords = 'Salesforce Developer';
        body.location = 'Omaha, NE';
        body.salary = '100000';
        body.dateCreatedFrom = '2024-07-01';

        // Set the mock callout class
		Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());

        Test.startTest();
        try{
            JoobleCallout.getJobsFromJooble(body);
        } catch (Exception e){
            System.assertEquals('Unauthorized endpoint, please check Setup->Security->Remote site settings.', e.getMessage(), 'Exception was not thrown as expected');
        }
        Test.stopTest();
    }


    @IsTest
    static void createJoobleCalloutBody(){
        // Create a list of FlowInputs to pass to the InvocableMethod in the CreateJoobleCalloutBodyAction
        List<CreateJoobleCalloutBodyAction.FlowInput> inputs = new List<CreateJoobleCalloutBodyAction.FlowInput>();
        CreateJoobleCalloutBodyAction.FlowInput inputOne = new CreateJoobleCalloutBodyAction.FlowInput();
        inputOne.keywords = 'Salesforce Developer';
        inputOne.location = 'Omaha, NE';
        inputOne.salary = '100000';
        inputOne.dateCreatedFrom = '2024-07-01';
        inputs.add(inputOne);

        // Set the mock callout class
		Test.setMock(HttpCalloutMock.class, new JoobleCalloutMockGenerator());

        Test.startTest();
        CreateJoobleCalloutBodyAction.createJoobleCalloutBody(inputs);
        Test.stopTest();

        //Query the records created by the callout mock and JoobleCalout
        List<Job_Application__c> newJobs = [SELECT Id, Salary_Type__c FROM Job_Application__c WITH SYSTEM_MODE];

        // Check that the Salary Type logic is working
        Integer annual = 0;
        Integer hourly = 0;
        Integer weekly = 0;
        for (Job_Application__c job : newJobs) {
            switch on job.Salary_Type__c {
                when 'Annual' {
                    annual++;
                }
                when 'Hourly' {
                    hourly++;
                }
                when 'Weekly' {
                    weekly++;
                }
            }
        }

        System.assertEquals(5, newJobs.size(), 'The incorrect number of jobs were created/exist');
        System.assertEquals(2, annual, 'The incorrect number of jobs were assigned the Salary Type of Annual');
        System.assertEquals(2, hourly, 'The incorrect number of jobs were assigned the Salary Type of Hourly');
        System.assertEquals(1, weekly, 'The incorrect number of jobs were assigned the Salary Type of Weekly');
    }

    @IsTest
    static void createJobsFromJSONTest(){
        // Create a ResponseResult from the JoobleCalloutMockGenerator
        List<JoobleCallout.ResponseResult> callResults = new List<JoobleCallout.ResponseResult>();
        JoobleCallout.ResponseResult jobsResponse = (JoobleCallout.Responseresult) JSON.deserialize(JoobleCalloutMockGenerator.JOOBLE_JSON_JOBS_PAYLOAD, JoobleCallout.ResponseResult.Class);
        callResults.add(jobsResponse);

        Test.startTest();
        List<Job_Application__c> newJobs = JoobleCallout.createJobsFromJSON(callResults);
        Test.stopTest();

        System.assertEquals(5, newJobs.size(), 'The incorrect number of jobs were returned');
    }

    @IsTest
    static void getExistingJoobleIdsTest(){
        // Create existing Job Application record to assert on upsert logic
        List<Job_Application__c> existingJobs = new List<Job_Application__c>();
        Job_Application__c jobOne = new Job_Application__c();
        jobOne.Jooble_Id__c = '4352497110792274330';
        existingJobs.add(jobOne);
        Job_Application__c jobTwo = new Job_Application__c();
        jobTwo.Jooble_Id__c = '1234567891234567891';
        existingJobs.add(jobTwo);
        Database.insert(existingJobs, AccessLevel.SYSTEM_MODE);

        // Create a ResponseResult from the JoobleCalloutMockGenerator
        List<JoobleCallout.ResponseResult> callResults = new List<JoobleCallout.ResponseResult>();
        JoobleCallout.ResponseResult jobsResponse = (JoobleCallout.Responseresult) JSON.deserialize(JoobleCalloutMockGenerator.JOOBLE_JSON_JOBS_PAYLOAD, JoobleCallout.ResponseResult.Class);
        callResults.add(jobsResponse);

        Test.startTest();
        Map<String, Job_Application__c> joobleIdToJobApp = JoobleCallout.getExistingJoobleIds(callResults);
        Test.stopTest();

        System.assertEquals(true, joobleIdToJobApp.containsKey(existingJobs[0].Jooble_Id__c), 'Existing matching Job Application record was not retrieved');
        System.assertEquals(false, joobleIdToJobApp.containsKey(existingJobs[1].Jooble_Id__c), 'Existing non-matching Job Application record was retrieved');
    }

    @IsTest
    static void getExistingAccountsTest(){
        // Create existing Account record to assert on upsert logic
        Account newAcc = new Account();
        newAcc.Name = 'DNI Talents Inc';
        Database.insert(newAcc, AccessLevel.SYSTEM_MODE);

        // Set key values that should match Company Names from the JoobleCalloutMockGenerator
        String keyOne = 'DNI Talents Inc';
        String keyTwo = 'Arcon Solutions Inc';
        String keyThree = 'Pride Health';
        String keyFour = 'The Reserves Network Inc';
        String keyFive = 'Cordova';

        // Create a ResponseResult from the JoobleCalloutMockGenerator
        List<JoobleCallout.ResponseResult> callResults = new List<JoobleCallout.ResponseResult>();
        JoobleCallout.ResponseResult jobsResponse = (JoobleCallout.Responseresult) JSON.deserialize(JoobleCalloutMockGenerator.JOOBLE_JSON_JOBS_PAYLOAD, JoobleCallout.ResponseResult.Class);
        callResults.add(jobsResponse);

        Test.startTest();
        Map<String, Account> companyNameToAccount = JoobleCallout.getExistingAccounts(callResults);
        Test.stopTest();

        // Verify the existing Account was not duplicated
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = 'DNI Talents Inc'];
        System.assertEquals(1, accs.size(), 'An Account was duplicated');

        // Verify that the correct number of Accounts were upserted
        List<Account> accsAll = [SELECT Id FROM Account];
        System.assertEquals(5, accsAll.size(), 'Not all Accounts were created');

        System.assertEquals(5, companyNameToAccount.size(), 'The incorrect number of Accounts were returned');
        System.assertEquals(true, companyNameToAccount.containsKey(keyOne), 'keyOne was not added to the map');
        System.assertEquals(true, companyNameToAccount.containsKey(keyTwo), 'keyTwo was not added to the map');
        System.assertEquals(true, companyNameToAccount.containsKey(keyThree), 'keyThree was not added to the map');
        System.assertEquals(true, companyNameToAccount.containsKey(keyFour), 'keyFour was not added to the map');
        System.assertEquals(true, companyNameToAccount.containsKey(keyFive), 'keyFive was not added to the map');
    }
}