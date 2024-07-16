trigger HiringTeamTrigger on Hiring_Team__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    HiringTeamHandler handler = new HiringTeamHandler();

    handler.run();
}