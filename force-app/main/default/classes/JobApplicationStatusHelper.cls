/**
 * @description       : This helper Class will create Tasks based on the Status of the Job Application.
 * @author            : Raghava
 * @group             : Cloud Smiths
 * @last modified on  : 07-20-2024
 * @last modified by  : Raghava
**/
public with sharing class JobApplicationStatusHelper {

    public static List<Task> tasksToBeCreated = new List<Task>();

    public static void tasksBasedOnStatus(List<Job_Application__c> newJobApplications, Map<Id, Job_Application__c> oldJobApplicationsMap){

        //Looping over all the Job Application records that are passed through After Update Trigger Context
        for(Job_Application__c jobApp : newJobApplications){
            //Check if this is an update operation and there is a change in the Status of the Job Application
            if(oldJobApplicationsMap != null && jobApp.Status__c != oldJobApplicationsMap.get(jobApp.Id).Status__c){
                handleStatusChange(jobApp.Status__c, jobApp);
            }
            //To create tasks when the Job Application is Inserted.
            else {
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
            createTask('Check if the job description aligns with your interests and values', 'High', jobApp);
            createTask('Review the highlighted skills to see if the role is a good fit', 'High', jobApp);
            createTask('Research the company or role and mark your excitement level', 'Medium', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Applying'
        when 'Applying' {
            createTask('Find and research someone who works at the company and add them as a contact', 'High', jobApp);
            createTask('Set up an informational interview to learn more about the role/company', 'Medium', jobApp);
            createTask('Identify potential referrals to help get your application on the top of the pile', 'High', jobApp);
            createTask('Customize your work achievements using the job description keywords', 'High', jobApp);
            createTask('Submit your application on the company website if possible', 'High', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Applied'
        when 'Applied' {
            createTask('Reach out to the hiring manager or recruiter', 'High', jobApp);
            createTask('Follow up on your application via email weekly', 'High', jobApp);
            createTask('Continue identifying and saving similar job opportunities', 'High', jobApp);
            createTask('Set up weekly networking calls to explore similar companies/roles', 'High', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Applied'
        when 'Interviewing' {
            createTask('Prepare your blurb or “tell me about yourself” response', 'High', jobApp);
            createTask('Practice answering behavioral interview questions', 'High', jobApp);
            createTask('Research the company and your interviewers', 'High', jobApp);
            createTask('Set up your virtual interview space and test your tech', 'High', jobApp);
            createTask('Send thank you emails within 24 hours', 'High', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Negotiating'
        when 'Negotiating' {
            createTask('Research your market value and know your numbers', 'High', jobApp);
            createTask('Prepare your negotiation scripts', 'High', jobApp);
            createTask('Evaluate your offer and decline or accept', 'High', jobApp);
        }

        ////Create the below Tasks when the Job Application Status is 'Accepted'

        when 'Accepted' {
            createTask('Plan your resignation if applicable', 'High', jobApp);
            createTask('Take some time to relax and recharge', 'High', jobApp);
            createTask('Prepare for your first day of onboarding', 'High', jobApp);
        }

        //Create the below Tasks when the Job Application Status is 'Closed'
        when 'Closed' { 
            createTask('Send a follow-up email thanking the interviewer and asking for feedback', 'High', jobApp);
            createTask('Review your notes and reflect on areas of improvement', 'High', jobApp);
        }
    }
}
    //Method to create Tasks
    public static void createTask(String description, String priority, Job_Application__c application){

        Task task = new Task();
        task.Description = description;
        task.Subject = 'Action Required';
        task.ActivityDate = System.today() + 1;
        task.Priority = priority;
        task.WhatId = application.Id;
        task.OwnerId = application.OwnerId;
        task.Status = 'In Progress';
        //Add this task to the list of Tasks to be Created
        tasksToBeCreated.add(task);
    }

}