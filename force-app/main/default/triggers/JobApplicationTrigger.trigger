trigger JobApplicationTrigger on Job_Application__c (before insert, after insert) {
    
    JobApplicationHandler handler = new JobApplicationHandler();
    handler.run();
    
}