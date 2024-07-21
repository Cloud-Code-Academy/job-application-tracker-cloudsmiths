trigger HiringTeamTrigger on Hiring_Team__c (after insert, after update) {
    
    HiringTeamHandler handler = new HiringTeamHandler();
    handler.run();
    
}