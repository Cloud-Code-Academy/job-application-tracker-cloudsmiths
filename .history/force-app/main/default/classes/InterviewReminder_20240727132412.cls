/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-27-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class InterviewReminder implements Schedulable {

    /**
    * You can run these lines of code in Developer Console > Apex Anonymous 
    * 
    **/

    // Allows this class to be scheduled nightly to send email reminders to interviewees
    public void execute (SchedulableContext sc) {
        sendEmailReminder();
    }

    public static void sendEmailReminder() {
        List<Event> scheduledInterviews = getScheduledInterviews();
        Map<Id, Job_Application__c> jobIdToJobApp = getJobApplicationRecords(scheduledInterviews);
        Map<Id, User> idToUser = getEmailAddresses(scheduledInterviews);
        Map<Id, Contact> idToContact = getContactRecords(scheduledInterviews, jobIdToJobApp);
        Map<Id, Account> idToAccount = getAccountRecords(jobIdToJobApp);
        Integer singleEmailLimit = 15;

        /**
        * Reserves email capacity to send single email to the specified number of email addresses, after the current transaction commits.
        * This limit is set for 5000 email recipients per day per org in Paid Orgs.
        * This limit is set for 15 email recipients per day per org in Developer Edition Orgs
        **/
        Messaging.reserveSingleEmailCapacity(singleEmailLimit);

        // Stores all of the emails to be sent
        List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();

        // Loop through each interview found for tomorrow and send an email to the interviewee (Event Owner)
        for (Event interview : scheduledInterviews) {
            String fromAddress = 'noreply@cloudsmiths.com';
            String fromDisplayName = 'Cloud Smiths Interview Reminder';
            List<String> toAddresses = new List<String>{idToUser.get(interview.OwnerId).Email};
            String subject = 'REMINDER: You have an interview tomorrow!';
            String htmlBody = 'Hello ' + idToUser.get(interview.OwnerId).FirstName + ',<br /><br />';
            htmlBody += 'You have an interview on ' + '<strong>' + interview.StartDateTime + ' at ' + interview.Location + ' with ' + idToContact.get(interview.WhoId).Name + '</strong> <br /><br />';
            htmlBody += '<strong>Interview Type:</strong> ' + interview.Interview_Type__c + '<br /><br />';
            htmlBody += '<strong>Interview Format:</strong> ' + interview.Interview_Format__c + '<br /><br />';
            htmlBody += '<br /><br /><strong><u>Job Information</u></strong><br /><br />';
            htmlBody += '<strong>Job App Name:</strong> ' + jobIdToJobApp.get(interview.WhatId).Name + '<br /><br />';
            htmlBody += '<strong>Company Name:</strong> ' + idToAccount.get(jobIdToJobApp.get(interview.WhatId).Company__c).Name + '<br /><br />';
            htmlBody += '<strong>Position/Title:</strong> ' + jobIdToJobApp.get(interview.WhatId).Position_Title__c + '<br /><br />';
            htmlBody += '<strong>Primary Contact:</strong> ' + idToContact.get(jobIdToJobApp.get(interview.WhatId).Primary_Contact__c).Name + '<br /><br />';
            htmlBody += '<strong>Location:</strong> ' + jobIdToJobApp.get(interview.WhatId).Location__c + '<br /><br />';
            htmlBody += '<strong>Location Type:</strong> ' + jobIdToJobApp.get(interview.WhatId).Location_Type__c + '<br /><br />';
            htmlBody += '<strong>Job Type:</strong> ' + jobIdToJobApp.get(interview.WhatId).Job_Type__c + '<br /><br />';
            htmlBody += '<strong>Salary:</strong> $' + jobIdToJobApp.get(interview.WhatId).Salary__c + '<br /><br />';
            htmlBody += '<strong>Salary Type:</strong> ' + jobIdToJobApp.get(interview.WhatId).Salary_Type__c + '<br /><br />';
            htmlBody += '<strong>Job Posting URL:</strong> ' + jobIdToJobApp.get(interview.WhatId).Job_Posting_URL__c + '<br /><br />';
            htmlBody += '<br /><br />You rated this job a ' + '<strong>' + jobIdToJobApp.get(interview.WhatId).Rating_Scale__c + ' / 5</strong><br /><br />';
            htmlBody += 'Do not forget to prepare for the interview and to show up at least 15 minutes early.<br /><br />';
            htmlBody += 'GOODLUCK!';
            Boolean saveAsActivity = true;

            // Ensure that there is an Owner assigned to the interveiw Event and ensure that we have the Owner's email
            if (interview.OwnerId != null && idToUser.containsKey(interview.OwnerId)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setReplyTo(fromAddress);
                mail.setSenderDisplayName(fromDisplayName);
                mail.setToAddresses(toAddresses);
                mail.setSubject(subject);
                mail.setHtmlBody(htmlBody);
                mail.setSaveAsActivity(saveAsActivity);
                allMsg.add(mail);
            }
        }

        // Send emails and retrieve result of sending emails
        Boolean optAllOrNone = false;
        if (!allMsg.isEmpty()){
            List<Messaging.SendEmailResult> allMsgResults = Messaging.sendEmail(allMsg, optAllOrNone);
            for (Messaging.SendEmailResult msgResult : allMsgResults) {
                if (msgResult.isSuccess()) {
                    System.debug('Email sent successfully');
                } else {
                    System.debug('Error: ' + msgResult.getErrors());
                }
            }
        }
    }

    @TestVisible
    private static List<Event> getScheduledInterviews() {
        // Query all interviews scheduled for tomorrow that have a WhatId and a Subject of Interview
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null AND StartDateTime = TOMORROW];

        // Remove Events not related to Job_Application__C reocrds
        for (Event interview : scheduledInterviews) {
            Id myId = interview.WhatId;
            Boolean jobApplicationRecord = myId.getSObjectType() == Job_Application__c.getSObjectType();
            if (!jobApplicationRecord) {
                Integer index = scheduledInterviews.indexOf(interview);
                scheduledInterviews.remove(index);
            }
        }

        return scheduledInterviews;
    }

    @TestVisible
    private static Map<Id, Job_Application__c> getJobApplicationRecords(List<Event> scheduledInterviews) {
        // Create a Set of all the Job Application record Ids related to tomorrows interviews
        Set<Id> jobAppIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            jobAppIds.add(interview.WhatId);
        }

        // Query all the Job Applicaiton records related to tomorrows interviews and store them in a Map
        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c, Primary_Contact__c, Location__c, Location_Type__c, Job_Type__c, Salary__c, Salary_Type__c, Job_Posting_URL__c, Rating_Scale__c
                                                        FROM Job_Application__c
                                                        WHERE Id IN :jobAppIds]);

        return jobIdToJobApp;
    }

    @TestVisible
    private static Map<Id, User> getEmailAddresses(List<Event> scheduledInterviews) {
        // Create a Set of all the Owner Ids for tomorrows interviews
        Set<Id> userIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            userIds.add(interview.OwnerId);
        }

        // Query all the User records for the Owner Ids
        List<User> interviewee = [SELECT Id, Email, FirstName, LastName, Name
                                    FROM User
                                    WHERE Id IN :userIds];

        // Create a Map of the Owner Id for tomorrows interviews to their User record
        Map<Id, User> idToUser = new Map<Id, User>();
        for (User i : interviewee) {
            if (!String.isEmpty(i.email)) {
                idToUser.put(i.Id, i);
            }
        }
        return idToUser;
    }

    @TestVisible
    private static Map<Id, Contact> getContactRecords(List<Event> scheduledInterviews, Map<Id, Job_Application__c> jobIdToJobApp) {
        // Create a set of Contact Ids related to tomorrows interviews and their related Job Application records
        Set<Id> contactIds = new Set<Id>();
        // Remove WhoId's not related to a Contact record from tomorrows Interviews
        for (Event interview : scheduledInterviews) {
            Id myId = interview.WhoId;
            Boolean contactRecord = myId.getSObjectType() == Contact.getSObjectType();
            if (myId != null && contactRecord){
                contactIds.add(interview.WhoId);
            }
        }

        // Add the Primary Contact Ids from the Job Application records to the set
        for (Id key : jobIdToJobApp.keySet()) {
            if (jobIdToJobApp.get(key).Primary_Contact__c != null) {
                contactIds.add(jobIdToJobApp.get(key).Primary_Contact__c);
            }
        }

        // Create a Map of the Id to the Contact records
        Map<Id, Contact> idToContact = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Name
                                                                FROM Contact
                                                                WHERE Id IN :contactIds]);
        return idToContact;
    }

    @TestVisible
    private static Map<Id, Account> getAccountRecords(Map<Id, Job_Application__c> jobIdToJobApp) {
        // Create a set of the Account Ids related to the Job Applications for tomorrows Interviews
        Set<Id> accountIds = new Set<Id>();
        for (Id key : jobIdToJobApp.keySet()) {
            accountIds.add(jobIdToJobApp.get(key).Company__c);
        }

        // Create a Map of Id to Account for the Account records
        Map<Id, Account> idToAccount = new Map<Id, Account>([SELECT Id, Name
                                                                FROM Account
                                                                WHERE Id IN :accountIds]);
        return idToAccount;
    }

}