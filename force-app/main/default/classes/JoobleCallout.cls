/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 08-01-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class JoobleCallout {

    // Wrapper Class for the ResponseResults
    public class ResponseResult {
        public Integer totalCount;
        public Jobs[] jobs;
    }

    // Wrapper Class for the Jobs array in the ResponseResults Class
    public class Jobs {
        public String title;
        public String location;
        public String snippet;
        public String salary;
        public String source;
        public String type;
        public String link;
        public String company;
        public String updated;
        public String id;
    }

    // Exception class
    public class JoobleException extends Exception {}

    public static void getJobsFromJooble(CreateJoobleCalloutBodyAction.FlowInput body) {
        // Jooble uses pagination when you make calls to their API
        Integer page = 1;
        Integer resultOnPage = 20;
        Boolean morePages = true;
        List<ResponseResult> callResults = new List<ResponseResult>();

        // This loop allows us to retrieve all the records for the search up to Salesforce callout limits
        while(morePages && page < 101){
            // Create the HttpRequest Body
            String callEndpoint = 'callout:JoobleAPI'; // This is a Named Credential
            String callMehtod = 'POST';
            Map<String, String> callHeader = new Map<String, String>{'Content-Type' => 'application/json'};
            String callBody = '{ "keywords": "' + body.keywords + '", ' + 
                                '"location": "' + body.location + '", ' + 
                                '"datecreatedfrom": "' + body.dateCreatedFrom + '", ' + 
                                '"salary": "' + body.salary + '", ' + 
                                '"page": "' + String.valueOf(page) + '", ' +
                                '"resultonpage": "' + String.valueOf(resultOnPage) + '" }';

            // Create HttpRequest to send to Jooble API
            HttpRequest request = new HttpRequest();
            request.setEndpoint(callEndpoint);
            request.setMethod(callMehtod);
            request.setHeader('Content-Type', callHeader.get('Content-Type'));
            request.setBody(callBody);

            Integer numAttempts = 3; // Maximum number of retry attempts
            while (numAttempts > 0) {
                try {
                    // Send the HTTP request and get the response
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                        // Deserialize the JSON string to ResponseResult wrapper class
                        ResponseResult jobsResponse = (Responseresult) JSON.deserialize(response.getBody(), ResponseResult.Class);
                        if (jobsResponse.jobs != null){
                            callResults.add(jobsResponse);
                        }
                        // Check if there are more results to retrieve and make another request if necessary
                        if (jobsResponse.jobs.size() < resultOnPage) {
                            morePages = false;
                            break;
                        } else {
                            page++;
                            break;
                        }
                    } else {
                        // Callout was not successful, decrement attempts and retry
                        numAttempts--;
                    }
                } catch (Exception ex) {
                    if(Test.isRunningTest()){
                        numAttempts--;
                        throw new JoobleException('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
                    } else {
                        // An exception occurred during the callout, decrement attempts and retry
                        numAttempts--;
                        throw new JoobleException('Callout failed: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
                    }
                }
            }

            // Prevent recalling the Jooble API if the callout fails 3 times
            if (numAttempts == 0) {
                morePages = false;
            }
        }

        // Create all the Job_Application__c records for upsert
        List<Job_Application__c> newJobs = createJobsFromJSON(callResults);

        // Upsert the Job_Application__c records matching on the Jooble_Id__c
        Schema.SObjectField ftoken = Job_Application__c.Fields.Jooble_Id__c;
        Database.upsert(newJobs, ftoken, AccessLevel.SYSTEM_MODE);
    }

    @TestVisible
    private static List<Job_Application__c> createJobsFromJSON(List<ResponseResult> callResults) {
        // Retrieve a Map of the existing Jooble Ids to Job_Application__c record
        Map<String, Job_Application__c> joobleIdToJobApp = getExistingJoobleIds(callResults);
        // Retrieve a map of the Company Name from Jooble to existing Accounts
        Map<String, Account> companyNameToAccount = getExistingAccounts(callResults);

        // List to store all the Job_Application__c records
        List<Job_Application__c> newJobs = new List<Job_Application__c>();
        // Iterate through the List of Jobs to create the Job_Application__c records
        for (ResponseResult jobsResponse : callResults) {
            for (Jobs j : jobsResponse.jobs){
                if (j != null) {
                    Job_Application__c tempJob = new Job_Application__c();
                    if (!String.isEmpty(j.id)) {
                        tempJob.Jooble_Id__c = (String) j.id;
                    }
                    if (!String.isEmpty(j.title)) {
                        tempJob.Position_Title__c = (String) j.title;
                    }
                    if (!String.isEmpty(j.link)) {
                        tempJob.Job_Posting_URL__c = (String) j.link;
                    }
                    if (!String.isEmpty(j.location)) {
                        tempJob.Location__c = (String) j.location;
                    }
                    if (!String.isEmpty(j.source)) {
                        tempJob.Jooble_Source__c = (String) j.source;
                    }
                    if (!String.isEmpty(j.updated)) {
                        tempJob.Jooble_Last_Updated__c = Date.valueOf(j.updated.substringBefore('T'));
                    }
                    if (!String.isEmpty(j.company) && companyNameToAccount.containsKey(j.company)){
                        tempJob.Company__c = companyNameToAccount.get(j.company).Id;
                    }
                    /** 
                    * The salary returned from Jooble is a String of either '$180k', '$180k - $250k', '$18 - $25 per hour', '$60 per hour' or '$2,124 per week'
                    * We will always return the lowest salary
                    **/
                    if (!String.isEmpty(j.salary)) {
                        // Check if salary is Annual, Weekly, or Hourly
                        if(j.salary.contains(',')) {
                            tempJob.Salary__c = Decimal.valueOf(j.salary.substringBefore(' ').replaceAll(',', '').substring(1));
                            tempJob.Salary_Type__c = 'Weekly';
                        } else if (j.salary.contains('k')){
                            tempJob.Salary__c = Decimal.valueOf(j.salary.substringBefore('k').substring(1));
                            tempJob.Salary_Type__c = 'Annual';
                        } else if (j.salary.contains('-')) {
                            tempJob.Salary__c = Decimal.valueOf(j.salary.deleteWhitespace().substringBefore('-').substring(1).replaceAll(',', ''));
                            tempJob.Salary_Type__c = 'Hourly';
                        } else {
                            tempJob.Salary__c = Decimal.valueOf(j.salary.substringBefore(' ').substring(1));
                            tempJob.Salary_Type__c = 'Hourly';
                        }
                    }
                    if (!String.isEmpty(j.type)) {
                        tempJob.Job_Type__c = j.type;
                    }
                    // Prevent the description from being overriden if the Job_Application__c record exists
                    if (!joobleIdToJobApp.containsKey(j.id)){
                        tempJob.description__c = j.snippet;
                    }
                    newJobs.add(tempJob);
                }
            }
        }
        return newJobs;
    }

    @TestVisible
    private static Map<String, Job_Application__c> getExistingJoobleIds(List<ResponseResult> callResults) {
        // Create a Set of the Jooble Ids returned from the callout
        Set<String> existingJoobleIds = new Set<String>();
        for (ResponseResult jobsResponse : callResults) {
            for (Jobs j : jobsResponse.jobs){
                existingJoobleIds.add(j.id);
            }
        }

        // Retrieve any existing Job_Application__c records that have a Jooble Id in the Set
        List<Job_Application__c> existingJobApplications = [SELECT Id, Jooble_Id__c, Position_Title__c, Salary__c, Salary_Type__c, Job_Posting_URL__c, Location__c, Job_Type__c, Company__c 
                                                            FROM Job_Application__c
                                                            WHERE Jooble_Id__c IN :existingJoobleIds
                                                            WITH SYSTEM_MODE];

        // Create a Map of the Jooble Id to the existing Job_Application__c record
        Map<String, Job_Application__c> joobleIdToJobApp = new Map<String, Job_Application__c>();
        for (Job_Application__c j : existingJobApplications) {
            joobleIdToJobApp.put(j.Jooble_Id__c, j);
        }

        return joobleIdToJobApp;
    }

    @TestVisible
    private static Map<String, Account> getExistingAccounts(List<ResponseResult> callResults) {
        // Create a Set to store all the Company names returned from Jooble
        Set<String> companyNames = new Set<String>();
        for (ResponseResult jobsResponse : callResults) {
            for (Jobs j : jobsResponse.jobs){
                if (!String.isEmpty(j.company)){
                    companyNames.add(j.company);
                }
            }
        }

        // Retrieve all the existing Accounts with a Name in the Set
        List<Account> existingAccounts = [SELECT Id, Name 
                                            FROM Account
                                            WHERE Name IN :companyNames
                                            WITH SYSTEM_MODE];

        // look through each unique Company Name returned from Jooble to determine if it exists already
        for (String companyName : companyNames) {
            Boolean accountExists = false;
            for (Account a : existingAccounts) {
                if (a.name == companyName) {
                    accountExists = true;
                    break;
                }
            }
            // If the Account does not exist, add a new Account record
            if (!accountExists) {
                Account newAcc = new Account();
                newAcc.Name = companyName;
                existingAccounts.add(newAcc);
            }
            accountExists = false;
        }
        // Upsert all the Accounts ensuring each one exists
        Database.upsert(existingAccounts, AccessLevel.SYSTEM_MODE);

        // Create a Map of the Company Name to the Account record
        Map<String, Account> companyNameToAccount = new Map<String, Account>();
        for (Account a : existingAccounts) {
            companyNameToAccount.put(a.Name, a);
        }

        return companyNameToAccount;
    }

}