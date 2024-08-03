/**
 * @description       : This test Class will create and update the Job Application records and verifies if respective  Tasks are created as per the Status of the Job Application.
 * @author            : Raghava
 * @group             : Cloud Smiths
 * @last modified on  : 07-20-2024
 * @last modified by  : Raghava
**/
@IsTest
public with sharing class JobApplicationStatusHelperTest {

    @IsTest
    static void jobApplicationAfterInsertTest(){

         //Create Test data
        List<Job_Application__c> jobApplications = new List<Job_Application__c>();
         //Create 5 Job Application records for each status value
        for(Integer i = 0; i < 35; i++){
             //Job Application with Status = 'Saved'
            if(i < 5) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Saved',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
             //Job Application with Status = 'Applying'
            if(i >= 5 && i < 10) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Applying',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
             //Job Application with Status = 'Applied'
            if(i >= 10 && i < 15) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Applied',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
             //Job Application with Status = 'Interviewing'
            if(i >= 15 && i < 20) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Interviewing',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
             //Job Application with Status = 'Negotiating'
            if(i >= 20 && i < 25) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Negotiating',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
             //Job Application with Status = 'Accepted'
            if(i >= 25 && i < 30) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Accepted',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
             //Job Application with Status = 'Closed'
            if(i >= 30 && i < 35) {
                Job_Application__c jobApp = new Job_Application__c (Status__c = 'Closed',
                                                                    Position_Title__c = 'Salesforce Dev' + i,
                                                                    Salary__c = 100000);
                jobApplications.add(jobApp);
            }
        }

        Test.startTest();
        Database.insert(jobApplications);
        Test.stopTest();

        //Assertion of Task records for each Status
        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Saved
        List<Task> savedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Saved%'];
        for(Task task : savedTasks ){
            System.assertEquals(15, savedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Saved');
            System.assertEquals(System.today() +1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - saved');
        }

        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Applying
        List<Task> applyingTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Applying%'];
        for(Task task : applyingTasks ){
            System.assertEquals(25, applyingTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Applying');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Applying');
        }

        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Applied
        List<Task> appliedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Applied%'];
        for(Task task : appliedTasks ){
            System.assertEquals(20, appliedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Applied');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Applied');
        }

        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Interviewing
        List<Task> interviewingTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Interviewing%'];
        for(Task task : interviewingTasks ){
            System.assertEquals(25, interviewingTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Interviewing');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Interviewing');
        }

        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Negotiating
        List<Task> negotiatingTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Negotiating%'];
        for(Task task : negotiatingTasks ){
            System.assertEquals(15, negotiatingTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Negotiating');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Negotiating');
        }

        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Accepted
        List<Task> acceptedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Accepted%'];
        for(Task task : acceptedTasks ){
            System.assertEquals(15, acceptedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Accepted');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Accepted');
        }

        //Asserting if the Tasks are inserted as expected when Job Application is created with Status = Closed
        List<Task> closedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Closed%'];
        for(Task task : closedTasks ){
            System.assertEquals(10, closedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Closed');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Closed');
        }

    }

    @IsTest
    static void jobApplicationAfterUpdateTest() {

        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        for(Integer i = 0; i < 50; i++){
            Job_Application__c jobApp = new Job_Application__c (Status__c = 'Saved',
                                                                Position_Title__c = 'Salesforce Dev ' + i,
                                                                Salary__c = 100000);
                jobApps.add(jobApp);
        }

        if(!jobApps.isEmpty()){
            Database.insert(jobApps);
        }

        //Update the Job Application record Status 
        List<Job_Application__c> jobAppsToBeUpdated = new List<Job_Application__c>();

        for(Job_Application__c jobApp : [SELECT Id,Name, Status__c, Position_Title__c, Salary__c FROM Job_Application__c]){
            if(Integer.valueOf(jobApp.Position_Title__c.substringAfter('Dev ')) < 25){
                jobApp.Status__c = 'Interviewing';
                jobAppsToBeUpdated.add(jobApp);
            }
            else {
                jobApp.Salary__c = 200000;
                jobAppsToBeUpdated.add(jobApp);
                }
            }

        Test.startTest();
        Database.update(jobAppsToBeUpdated);
        Test.stopTest();

        //Asserting that the tasks are properly created when the Status is updated to 'Interviewing'
        List<Task> interviewingTasks = [SELECT Id,Description, Priority, ActivityDate, WhatId FROM Task WHERE Subject LIKE 'Interviewing%'];
        for(Task task : interviewingTasks){
            System.assertEquals (125, interviewingTasks.size(),'Tasks are not created as Expected for the Job Application with Status - Interviewing after Update');
            System.assertEquals(System.today() + 1, task.ActivityDate , 'Tasks Due Date is not set as expected for the Job Applications with Status - Interviewing after Update');
        }

        //Negative Assertion
        //Asserting that there are no tasks created when the Status is not updated.
        List<Job_Application__c> nonInterviewingJobApps = [SELECT Id, Status__c FROM Job_Application__c WHERE Status__c != 'Interviewing'];
        List<Task> nonInterviewingTasks = [SELECT Id FROM Task WHERE WhatId IN : nonInterviewingJobApps ];
        for(Task task : nonInterviewingTasks){
            System.assertEquals (75, nonInterviewingTasks.size(),'Tasks are created for the Job Application even not updating the Status field.');
        }
    }

}