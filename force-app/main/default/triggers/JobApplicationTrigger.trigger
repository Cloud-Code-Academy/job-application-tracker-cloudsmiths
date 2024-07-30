trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, before update, after update) {
    
    JobApplicationHandler handler = new JobApplicationHandler();
    handler.run();
    
}