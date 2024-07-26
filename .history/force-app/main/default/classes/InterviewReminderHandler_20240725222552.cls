/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-25-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class InterviewReminderHandler {

    public static void sendEmailReminder() {
        List<Event> scheduledInterviews = getScheduledInterviews();
        Map<Id, Job_Application__c> jobIdToJobApp = getJobApplicationRecords(scheduledInterviews);
        Map<Id, User> idToUser = getEmailAddresses(scheduledInterviews);
        Map<Id, Contact> idToContact = getContactRecords(scheduledInterviews, jobIdToJobApp);
        Map<Id, Account> idToAccount = getAccountRecords(jobIdToJobApp);
        Integer numberOfInterviews = scheduledInterviews.size();

        // Reserves email capacity to send single email to the specified number of email addresses, after the current transaction commits.
        Messaging.reserveSingleEmailCapacity(numberOfInterviews);

        // Stores all of the emails to be sent
        List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();

        // Loop through each interview found for tomorrow and send an email to the interviewee (Event Owner)
        for (Event interview : scheduledInterviews) {
            String fromAddress = 'noreply@cloudsmiths.com';
            String fromDisplayName = 'Cloud Smiths Interview Reminder';
            List<String> toAddresses = new List<String>{idToUser.get(interview.OwnerId).Email};
            String subject = 'REMINDER: You have an interview tomorrow!';
            String htmlBody = 'Hello ' + idToUser.get(interview.OwnerId).FirstName + ',<br /><br />';
            htmlBody += 'You have an interview on ' + '<strong>' + interview.StartDateTime + ' at ' + interview.Location + ' with ' + interview.WhoId + '</strong> <br /><br />';
            htmlBody += '<strong>Interview Type:</strong> ' + interview.Interview_Type__c + '<br /><br />';
            htmlBody += '<strong>Interview Format:</strong> ' + interview.Interview_Format__c + '<br /><br />';
            htmlBody += '<br /><br /><strong><u>Job Information</u></strong><br /><br />';
            htmlBody += '<strong>Job App Name:</strong> ' + jobIdToJobApp.get(interview.WhatId).Name + '<br /><br />';
            htmlBody += '<strong>Company Name:</strong> ' + jobIdToJobApp.get(interview.WhatId).Company__c + '<br /><br />';
            htmlBody += '<strong>Position/Title:</strong> ' + jobIdToJobApp.get(interview.WhatId).Position_Title__c + '<br /><br />';
            htmlBody += '<strong>Primary Contact:</strong> ' + jobIdToJobApp.get(interview.WhatId).Primary_Contact__c + '<br /><br />';
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
            System.debug('FROM: ' + fromAddress);
            System.debug('FROM DISPLAY NAME: ' + fromDisplayName);
            System.debug('TO: ' + toAddresses);
            System.debug('SUBJECT: ' + subject);
            System.debug('BODY: ' + htmlBody);
            System.debug('SAVE AS ACTIVITY: ' + saveAsActivity);

            // Ensure that there is an Owner assigned to the interveiw Event and then ensure that we have the Owner's email
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
        List<Messaging.SendEmailResult> allMsgResults = Messaging.sendEmail(allMsg, optAllOrNone); // max of 100 "To" recipients...
        for (Messaging.SendEmailResult msgResult : allMsgResults) {
            if (msgResult.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                System.debug('Error: ' + msgResult.getErrors());
            }
        }
        System.debug('Total Email Invociations: ' + Limits.getEmailInvocations() + ' / ' + Limits.getLimitEmailInvocations());
    }

    @TestVisible
    private static List<Event> getScheduledInterviews() {
        // Query all interviews scheduled for tomorrow
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
        // Create a Set of all the Job Application record Id's
        Set<Id> jobAppIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            jobAppIds.add(interview.WhatId);
        }

        // Query all the Job Applicaiton records related to the interview Events and store them in a Map
        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c, Primary_Contact__c, Location__c, Location_Type__c, Job_Type__c, Salary__c, Salary_Type__c, Job_Posting_URL__c, Rating_Scale__c
                                                        FROM Job_Application__c
                                                        WHERE Id IN :jobAppIds]);

        return jobIdToJobApp;
    }

    @TestVisible
    private static Map<Id, User> getEmailAddresses(List<Event> scheduledInterviews) {
        // Create a Set of all the Event OwnerId's
        Set<Id> userIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            userIds.add(interview.OwnerId);
        }

        // Query all the User records for the OwnerId's
        List<User> interviewee = [SELECT Id, Email, FirstName, LastName
                                    FROM User
                                    WHERE Id IN :userIds];

        // Create a Map of the OwnerId for the interview Event to their Email
        Map<Id, User> userToEmail = new Map<Id, User>();
        for (User i : interviewee) {
            if (!String.isEmpty(i.email)) {
                userToEmail.put(i.Id, i);
            }
        }
        return userToEmail;
    }

    @TestVisible
    private static Map<Id, Contact> getContactRecords(List<Event> scheduledInterviews, Map<Id, Job_Application__c> jobIdToJobApp) {
        Set<Contact> contactIds = new Set<Contact>();
        for (Event interview : scheduledInterviews) {
            if (interview.WhoId){
                contactIds.add(interview.WhoId);
            }

        for ()
    }

}