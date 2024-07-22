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

        for (Event interview : scheduledInterviews) {
            Id myId = interview.WhatId;
            Boolean jobApplicationRecord = myId.getSObjectType() == Job_Application__c.getSObjectType();
            if (jobApplicationRecord) {
                sendEmail(interview);
            }
            System.debug(myId.getSObjectType());
        }
        
        List<Id> jobAppIds = new List<Id>();
        for (Event interview : scheduledInterviews) {
            if (!interview.WhatId) {
                jobAppIds.add(interview.WhatId);
            }
        }
    }

}