/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-21-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class InterviewReminderHandler {

    public static void sendEmailReminder() {
        List<Event> scheduledInterviews = getScheduledInterviews();
        Map<Id, Job_Application__c> jobIdToJobApp = getJobApplicationRecords(scheduledInterviews);
        Map<Id, String> userToEmail = getEmailAddresses(scheduledInterviews);
        Integer numberOfInterviews = scheduledInterviews.size();

        Messaging.reserveSingleEmailCapacity(numberOfInterviews);

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