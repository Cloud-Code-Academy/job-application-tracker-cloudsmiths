/**
 * @description       : This helper Class will create Tasks based on the Status of the Job Application.
 * @author            : Raghava
 * @group             : Cloud Smiths
 * @last modified on  : 07-20-2024
 * @last modified by  : Raghava
**/
public with sharing class JobApplicationStatusHelper {

    //Creating the static list to collect the tasks to be created.
    private static List<Task> tasksToBeCreated = new List<Task>();

    public static void tasksBasedOnStatus(List<Job_Application__c> newJobApplications, Map<Id, Job_Application__c> oldJobApplicationsMap){

        System.debug('Trigger Operation:::: ' + Trigger.operationType.name());
        //Clearing the static list to avoid retaining tasks from previous transactions
        tasksToBeCreated.clear();

        //Looping over all the Job Application records that are passed through After Update Trigger Context
        for(Job_Application__c jobApp : newJobApplications){
            if(Trigger.operationType.name() == 'AFTER_INSERT' || (Trigger.operationType.name() == 'AFTER_UPDATE' && jobApp.Status__c != oldJobApplicationsMap.get(jobApp.Id).Status__c)){
                handleStatusChange(jobApp.Status__c, jobApp);
            }
    }

    if(!tasksToBeCreated.isEmpty()){
        Database.insert(tasksToBeCreated, AccessLevel.SYSTEM_MODE);
    }
}

private static void handleStatusChange(String status, Job_Application__c jobApp){
    switch on status {

        //Create the below tasks when the Job Application Status is 'Saved'
        when 'Saved' {
            createTask('Check if the job description aligns with your interests and values','Saved Job Application Action Required', jobApp);
            createTask('Review the highlighted skills to see if the role is a good fit','Saved Job Application Action Required', jobApp);
            createTask('Research the company or role and mark your excitement level','Saved Job Application Action Required', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Applying'
        when 'Applying' {
            createTask('Find and research someone who works at the company and add them as a contact','Applying Job Application Action Required', jobApp);
            createTask('Set up an informational interview to learn more about the role/company','Applying Job Application Action Required', jobApp);
            createTask('Identify potential referrals to help get your application on the top of the pile','Applying Job Application Action Required', jobApp);
            createTask('Customize your work achievements using the job description keywords','Applying Job Application Action Required', jobApp);
            createTask('Submit your application on the company website if possible','Applying Job Application Action Required', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Applied'
        when 'Applied' {
            createTask('Reach out to the hiring manager or recruiter','Applied Job Application Action Required', jobApp);
            createTask('Follow up on your application via email weekly','Applied Job Application Action Required', jobApp);
            createTask('Continue identifying and saving similar job opportunities','Applied Job Application Action Required', jobApp);
            createTask('Set up weekly networking calls to explore similar companies/roles','Applied Job Application Action Required', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Applied'
        when 'Interviewing' {
            createTask('Prepare your blurb or “tell me about yourself” response','Interviewing Job Application Action Required', jobApp);
            createTask('Practice answering behavioral interview questions','Interviewing Job Application Action Required', jobApp);
            createTask('Research the company and your interviewers','Interviewing Job Application Action Required', jobApp);
            createTask('Set up your virtual interview space and test your tech','Interviewing Job Application Action Required', jobApp);
            createTask('Send thank you emails within 24 hours','Interviewing Job Application Action Required', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Negotiating'
        when 'Negotiating' {
            createTask('Research your market value and know your numbers','Negotiating Job Application Action Required', jobApp);
            createTask('Prepare your negotiation scripts','Negotiating Job Application Action Required', jobApp);
            createTask('Evaluate your offer and decline or accept','Negotiating Job Application Action Required', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Accepted'
        when 'Accepted' {
            createTask('Plan your resignation if applicable','Accepted Job Application Action Required', jobApp);
            createTask('Take some time to relax and recharge','Accepted Job Application Action Required', jobApp);
            createTask('Prepare for your first day of onboarding','Accepted Job Application Action Required', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Closed'
        when 'Closed' { 
            createTask('Send a follow-up email thanking the interviewer and asking for feedback','Closed Job Application Action Required', jobApp);
            createTask('Review your notes and reflect on areas of improvement','Closed Job Application Action Required', jobApp);
        }
    }
}
    //Method to create Tasks
    private static void createTask(String description, String subject, Job_Application__c application){

        Task task = new Task();
        task.Description = description;
        task.Subject = subject;
        task.ActivityDate = Date.today().addDays(1);
        task.Priority = 'High';
        task.WhatId = application.Id;
        task.OwnerId = application.OwnerId;
        task.Status = 'Not Started';
        //Add this task to the list of Tasks to be Created
        tasksToBeCreated.add(task);
    }
}