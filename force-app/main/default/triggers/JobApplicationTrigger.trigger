trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, after update) {
    
    JobApplicationHandler handler = new JobApplicationHandler();
    handler.run();
    
}