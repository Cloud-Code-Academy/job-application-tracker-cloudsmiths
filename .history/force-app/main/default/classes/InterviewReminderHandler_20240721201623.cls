/**
 * @description       : 
 * @author            : Riley Meyer
 * @group             : 
 * @last modified on  : 07-21-2024
 * @last modified by  : Riley Meyer
**/
public with sharing class InterviewReminderHandler {

    public static void sendEmailReminder() {
        List<Event> scheduledInterviews = [SELECT Id, WhoId, WhatId, Subject, Location, StartDateTime, EndDateTime, Interview_Format__c, Interview_Type__c 
                                            FROM Event
                                            WHERE Subject = 'Interview'];

        // Remove Events not related to Job_Application__C reocrds
        for (Event interview : scheduledInterviews) {
            Id myId = interview.WhatId;
            Boolean jobApplicationRecord = myId.getSObjectType() == Job_Application__c.getSObjectType();
            if (!jobApplicationRecord) {
                Integer index = scheduledInterviews.indexOf(interview);
                scheduledInterviews.remove(index);
            }
        }
        
        List<Job_Application__c> jobApps = [SELECT Id, Name, Candidate__c, Primary_Contact__c, Status__c, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Email
                                            FROM Job_Application__c
                                            WHERE Id IN :scheduledInterviews];

        List<Id> jobAppIds = new List<Id>();
        for (Event interview : scheduledInterviews) {
            if (!interview.WhatId) {
                jobAppIds.add(interview.WhatId);
            }
        }
    }

    public static List<Job_Application__c> getJobApplicationRecords(List<Event> scheduledInterviews) {

    }

}