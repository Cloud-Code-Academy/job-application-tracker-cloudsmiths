/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-24-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class InterviewReminderHandler {

    public static void sendEmailReminder() {
        List<Event> scheduledInterviews = getScheduledInterviews();
        Map<Id, Job_Application__c> jobIdToJobApp = getJobApplicationRecords(scheduledInterviews);
        Map<Id, String> userToEmail = getEmailAddresses(scheduledInterviews);
        Integer numberOfInterviews = scheduledInterviews.size();

        Messaging.reserveSingleEmailCapacity(numberOfInterviews);

        List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();

        for (Event interview : scheduledInterviews) {
            String fromAddress = 'noreply@cloudsmiths.com';
            String fromDisplayName = 'Cloud Smiths Interview Reminder';
            String subject = 'REMINDER: You have an interview tomorrow!';
            String htmlBody = 'Hello ' + interview.OwnerId.FirstName + ',<br /><br />';
            htmlBody += '<br /><br />You have an interview on ' + interview.StartDateTime + ' at ' + interview.Location + ' with ' + interview.Name + '<br /><br />';
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


            System.debug(htlmBody);
            Boolean saveAsActivity = true;

            if (interview.OwnerId != null && userToEmail.containsKey(interview.OwnerId)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setReplyTo(fromAddress);
                mail.setSenderDisplayName(fromDisplayName);
                mail.setToAddresses(userToEmail.get(interview.OwnerId));
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
        List<Event> scheduledInterviews = [SELECT Id, OwnerId, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c 
                                            FROM Event
                                            WHERE Subject = 'Interview' AND WhatId != null];

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
        Set<Id> jobAppIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            jobAppIds.add(interview.WhatId);
        }

        Map<Id, Job_Application__c> jobIdToJobApp = new Map<Id, Job_Application__c>([SELECT Id, Name, Company__c, Position_Title__c
                                                        FROM Job_Application__c
                                                        WHERE Id IN :jobAppIds]);

        return jobIdToJobApp;
    }

    @TestVisible
    private static Map<Id, String> getEmailAddresses(List<Event> scheduledInterviews) {
        Set<Id> userIds = new Set<Id>();
        for (Event interview : scheduledInterviews) {
            userIds.add(interview.OwnerId);
        }

        List<User> interviewee = [SELECT Id, Email
                                    FROM User
                                    WHERE Id IN :userIds];

        Map<Id, String> userToEmail = new Map<Id, String>();
        for (User i : interviewee) {
            if (!String.isEmpty(i.email)) {
                userToEmail.put(i.Id, i.Email);
            }
        }
        return userToEmail;
    }

}