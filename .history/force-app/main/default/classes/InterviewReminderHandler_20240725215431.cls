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
            htmlBody += '<br /><br />You have an interview on ' + interview.StartDateTime + ' at ' + interview.Location + ' with ' + interview.WhoId + '<br /><br />';
            htmlBody += '<br /><br />Interview Type: ' + interview.Interview_Type__c + '<br /><br />';
            htmlBody += 'Interview Format: ' + interview.Interview_Format__c + '<br /><br />';
            htmlBody += '<br /><br />Job Information:<br /><br />';
            htmlBody += 'Job App Name: ' + jobIdToJobApp.get(interview.WhatId).Name + '<br /><br />';
            htmlBody += 'Company Name: ' + jobIdToJobApp.get(interview.WhatId).Company__c + '<br /><br />';
            htmlBody += 'Position/Title: ' + jobIdToJobApp.get(interview.WhatId).Position_Title__c + '<br /><br />';
            htmlBody += 'Primary Contact: ' + jobIdToJobApp.get(interview.WhatId).Primary_Contact__c + '<br /><br />';
            htmlBody += 'Location: ' + jobIdToJobApp.get(interview.WhatId).Location__c + '<br /><br />';
            htmlBody += 'Location Type: ' + jobIdToJobApp.get(interview.WhatId).Location_Type__c + '<br /><br />';
            htmlBody += 'Job Type: ' + jobIdToJobApp.get(interview.WhatId).Job_Type__c + '<br /><br />';
            htmlBody += 'Salary: ' + jobIdToJobApp.get(interview.WhatId).Salary__c + '<br /><br />';
            htmlBody += 'Salary Type: ' + jobIdToJobApp.get(interview.WhatId).Salary_Type__c + '<br /><br />';
            htmlBody += 'Job Posting URL: ' + jobIdToJobApp.get(interview.WhatId).Job_Posting_URL__c + '<br /><br />';
            htmlBody += '<br /><br />You rated this job a ' + jobIdToJobApp.get(interview.WhatId).Rating_Scale__c + ' / 5<br /><br />';
            htmlBody += '<br /><br />Do not forget to prepare for the interview and to show up at least 15 minutes early.<br /><br />';
            htmlBody += '<br /><br />GOODLUCK!<br /><br />';
            System.debug(htmlBody);
            Boolean saveAsActivity = true;

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
        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c
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

}