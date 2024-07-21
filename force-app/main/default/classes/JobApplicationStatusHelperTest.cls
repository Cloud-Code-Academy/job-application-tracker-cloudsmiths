/**
 * @description       : This test Class will create and update the Job Application records and verifies if respective  Tasks are created as per the Status of the Job Application.
 * @author            : Raghava
 * @group             : Cloud Smiths
 * @last modified on  : 07-20-2024
 * @last modified by  : Raghava
**/
@IsTest
public with sharing class JobApplicationStatusHelperTest {

    static void createTestData(){
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
        
        Database.insert(jobApplications);
        
    }

    @IsTest
    static void jobApplicationAfterInsertTest(){

        List<Job_Application__c> insertedJobApps = [SELECT Id,Status__c, Position_Title__c, Salary__c FROM Job_Application__c ];
        
        //Assertion of Task records for each Status

        //Get Job Application records that are inserted and Status = 'Saved'
        List<Job_Application__c> savedJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Saved'];
        List<Task> savedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : savedJobApplications];

        for(Task task : savedTasks ){
            System.assertEquals(15, savedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Saved');
            System.assertEquals(System.today() +1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - saved');
        }

        //Get Job Application records that are inserted and Status = 'Applying'
        List<Job_Application__c> applyingJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Applying'];
        List<Task> applyingTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : applyingJobApplications];

        for(Task task : applyingTasks ){
            System.assertEquals(25, applyingTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Applying');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Applying');
        }

        //Get Job Application records that are inserted and Status = 'Applied'
        List<Job_Application__c> appliedJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Applied'];
        List<Task> appliedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : appliedJobApplications];

        for(Task task : appliedTasks ){
            System.assertEquals(20, appliedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Applied');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Applied');
        }

        //Get Job Application records that are inserted and Status = 'Interviewing'
        List<Job_Application__c> interviewingJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Interviewing'];
        List<Task> interviewingTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : interviewingJobApplications];

        for(Task task : interviewingTasks ){
            System.assertEquals(25, interviewingTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Interviewing');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Interviewing');
        }

        //Get Job Application records that are inserted and Status = 'Negotiating'
        List<Job_Application__c> negotiatingJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Negotiating'];
        List<Task> negotiatingTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : negotiatingJobApplications];

        for(Task task : negotiatingTasks ){
            System.assertEquals(15, negotiatingTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Negotiating');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Negotiating');
        }

        //Get Job Application records that are inserted and Status = 'Accepted'
        List<Job_Application__c> acceptedJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Accepted'];
        List<Task> acceptedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : acceptedJobApplications];

        for(Task task : acceptedTasks ){
            System.assertEquals(15, acceptedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Accepted');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Accepted');
        }

        //Get Job Application records that are inserted and Status = 'Accepted'
        List<Job_Application__c> closedJobApplications = [SELECT Id, Status__c, Position_Title__c, Salary__c 
                                                        FROM Job_Application__c WHERE Id IN:insertedJobApps AND Status__c = 'Closed'];
        List<Task> closedTasks = [SELECT Id, Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : closedJobApplications];

        for(Task task : closedTasks ){
            System.assertEquals(10, closedTasks.size(), 'Tasks are not created as Expected for the Job Application with Status - Closed');
            System.assertEquals(System.today() + 1, task.ActivityDate, 'Due Date of the Task is not set as Expected for Job Applications with Status - Closed');
        }

    }

    @IsTest
    static void jobApplicationAfterUpdateTest() {

        List<Job_Application__c> jobApplications = [SELECT Id,Status__c, Position_Title__c, Salary__c FROM Job_Application__c ];
        //Update the Job Application record Status 
        List<Job_Application__c> jobAppsToBeUpdated = new List<Job_Application__c>();

        for(Job_Application__c jobApp : jobApplications){
            switch on jobApp.Status__c{
                when 'Saved', 'Applying', 'Applied'{
                    jobApp.Status__c = 'Interviewing';
                    jobAppsToBeUpdated.add(jobApp);
                }
                when 'Negotiating', 'Accepted'{
                    jobApp.Status__c = 'Closed';
                    jobAppsToBeUpdated.add(jobApp);
                }
            }
        }

        Test.startTest();
        Database.update(jobAppsToBeUpdated);
        Test.stopTest();

        //Assertion of the Task creations after Status Update
        List<Job_Application__c> interviewingJobApps = [SELECT Id, Status__c FROm Job_Application__c WHERE Id IN : jobAppsToBeUpdated AND Status__c = 'Interviewing' ];
        List<Task> interviewingTasks = [SELECT Id,Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : interviewingJobApps ];

        for(Task task : interviewingTasks){
            System.assertEquals (125, interviewingTasks.size(),'Tasks are not created as Expected for the Job Application with Status - Interviewing after Update' );
            System.assertEquals(System.today() + 1, task.ActivityDate , 'Tasks Due Date is not set as expected for the Job Applications with Status - Interviewing after Update');
        }

        
        List<Job_Application__c> closedJobApps = [SELECT Id, Status__c FROm Job_Application__c WHERE Id IN : jobAppsToBeUpdated AND Status__c = 'Closed' ];
        List<Task> closedTasks = [SELECT Id,Description, Priority, ActivityDate, WhatId FROM Task WHERE WhatId IN : closedJobApps ];

        for(Task task : closedTasks){
            System.assertEquals (40, closedTasks.size(),'Tasks are not created as Expected for the Job Application with Status - Closed after Update' );
            System.assertEquals(System.today() + 1, task.ActivityDate , 'Tasks Due Date is not set as expected for the Job Applications with Status - Closed after Update');
        }
    }

}