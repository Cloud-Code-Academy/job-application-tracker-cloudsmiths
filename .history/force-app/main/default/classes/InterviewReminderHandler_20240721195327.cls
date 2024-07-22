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
        
    }

}