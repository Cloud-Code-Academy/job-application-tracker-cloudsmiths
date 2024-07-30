public with sharing class JobApplicationHandler extends TriggerHandler {

    //Initialize variables 
    private List<Job_Application__c> newJobApplications;
    private List<Job_Application__c> oldJobApplications;
    private Map<Id, Job_Application__c> newJobApplicationMap;
    private Map<Id, Job_Application__c> oldJobApplicationMap;

    //Setting variables with values from trigger
    public JobApplicationHandler() {

        this.newJobApplications = (List<Job_Application__c>) Trigger.new;
        this.oldJobApplications = (List<Job_Application__c>) Trigger.old;
        this.newJobApplicationMap = (Map<Id, Job_Application__c> ) Trigger.newMap;
        this.oldJobApplicationMap = (Map<Id, Job_Application__c> ) Trigger.oldMap;
    }

    public override void beforeInsert(){
        setPrimaryContact(newJobApplications);

    }

    public override void afterInsert(){
        List<Hiring_Team__c> hiringTeamList = createMissingHiringTeam(newJobApplications);
        TriggerHandler.bypass('HiringTeamHandler');
        Database.insert (hiringTeamList, AccessLevel.SYSTEM_MODE);
        TriggerHandler.clearAllBypasses();
        //Method to create Tasks for the Job Application record based on the Status of the Application
        JobApplicationStatusHelper.tasksBasedOnStatus(newJobApplications, oldJobApplicationMap);
    }

    public override void afterUpdate(){
        //The below method creates Tasks for Job Application record based on the Status of the Application
        JobApplicationStatusHelper.tasksBasedOnStatus(newJobApplications, oldJobApplicationMap);
    }

    public static void setPrimaryContact(List<Job_Application__c> newJobApplications){
        //Initialize list of Account Ids and map of Account Ids by Job Application Ids and populate the list and map
        List<Id> accountIdList = new List<Id>();
        Map<Id,Id> accountIdByJobAppIdMap = new Map<Id,Id>();
        for(Job_Application__c jobApp :newJobApplications){
            accountIdList.add(jobApp.Company__c);
            accountIdByJobAppIdMap.put(jobApp.Id, jobApp.Company__c);
        }
        //Use Account Id list to query list of Contact
        List<Contact> contactList = [SELECT Id, Name, CreatedDate,AccountId FROM Contact WHERE AccountId IN :accountIdList Order By CreatedDate ASC];
        //Initialize map of Contact Ids by Account Ids and populate the map
        Map<Id,Id> contactIdByAccountIdMap = new Map<Id,Id>();
        for(Contact con :contactList){
            if(!contactIdByAccountIdMap.containsKey(con.AccountId)){
                contactIdByAccountIdMap.put(con.AccountId,con.Id);
            }
        }

        /**For each Job Application if Primary Contact is null, the Job Application is in the Account Id map, 
        and the Account is in the Contact Id map, set the Primary Contact
        **/
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c == null && accountIdByJobAppIdMap.containsKey(jobApp.Id) && contactIdByAccountIdMap.containsKey(jobApp.Company__c)){
                jobApp.Primary_Contact__c = contactIdByAccountIdMap.get(jobApp.Company__c);
            }
        }
    }

    public static List<Hiring_Team__c> createMissingHiringTeam(List<Job_Application__c> newJobApplications){
        //Initialze lists of Hiring Team and Job Application Ids
        List<Hiring_Team__c> hiringTeamList = new List<Hiring_Team__c>();
        List<Id> jobAppId = new List<Id>();
        //Initialize map of Contacts by Job Application Id 
        Map<Id,Id> contactByJobAppIdMap = new Map<Id,Id>();
        //Populate the Job Application Id list and map
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c != null){
                jobAppId.add(jobApp.Id);
                contactByJobAppIdMap.put(jobApp.Id, jobApp.Primary_Contact__c);
            }
        }

        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Primary_Contact__c == null){
                continue;
            }
            Hiring_Team__c newHiringTeam = new Hiring_Team__c (Job_Application__c = jobApp.Id, Contact__c = contactByJobAppIdMap.get(jobApp.Id), Primary_Contact__c = true);
            hiringTeamList.add(newHiringTeam);
        }
        return hiringTeamList;
    }

    public static void taxWithholdingCalculator(List<Job_Application__c> newJobApplications){
        //Assign tax filing status
        List<String> filingStatus = new List<String>();
        List<Decimal> salaryAmount = new List<Decimal>();
        Integer weeklyHours = 40;
        Integer weeksInYear = 52;
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Tax_Filing_Status__c != null){
                filingStatus.add(jobApp.Tax_Filing_Status__c);
            }
            salaryAmount.add(annualSalaryCalculator(jobApp));
        }
        //Get Tax rate data
        List<Tax_Withholding__mdt> federalTaxRates = [SELECT Id, Tax_Rate__c, Type__c, Filing_Status__c, Minimum_Amount__c, Maximum_Amount__c 
                                                FROM Tax_Withholding__mdt
                                                WHERE Filing_Status__c IN :filingStatus
                                                Order By Tax_Rate__c ASC];
        Tax_Withholding__mdt socialSecurityRateRecord = [SELECT Id, Tax_Rate__c, Type__c, Filing_Status__c, Minimum_Amount__c, Maximum_Amount__c 
                                                    FROM Tax_Withholding__mdt
                                                    WHERE Type__c = 'Social Security'];
        Tax_Withholding__mdt medicareRateRecord = [SELECT Id, Tax_Rate__c, Type__c, Filing_Status__c, Minimum_Amount__c, Maximum_Amount__c 
                                                    FROM Tax_Withholding__mdt
                                                    WHERE Type__c = 'Medicare'];
        Decimal socialSecurityRate = socialSecurityRateRecord.Tax_Rate__c;
        Decimal medicareRate = medicareRateRecord.Tax_Rate__c;
        
        //Initial map of Job Applications By Id and populate the map
        Map<Id,Job_Application__c> jobApplictionByIdMap = new Map<Id,Job_Application__c>();
        for(Job_Application__c jobApp :newJobApplications){
            if(!jobApplictionByIdMap.containsKey(jobApp.Id)){
                jobApplictionByIdMap.put(jobApp.Id, jobApp);
            }
        }

        for(Job_Application__c jobApp :newJobApplications){
            Decimal annualSalary = annualSalaryCalculator(jobApp);
            Decimal remainingSalary = annualSalary;
            Decimal socialSecurityWithheld = annualSalary * socialSecurityRate;
            Decimal medicareWithheld = annualSalary * medicareRate;
            Decimal taxWithheld = medicareWithheld + socialSecurityWithheld;
            for(Tax_Withholding__mdt taxRate :federalTaxRates){
                Decimal rate = taxRate.Tax_Rate__c / 100;
                if(annualSalary != null && annualSalary >= taxRate.Minimum_Amount__c && annualSalary <= taxRate.Maximum_Amount__c){
                    taxWithheld = annualSalary * rate;
                    remainingSalary -= taxWithheld;
                }
            }
        }
    }

    public static Decimal annualSalaryCalculator(Job_Application__c jobApp){
        Decimal annualSalary = 0;
        Integer weeklyHours = 40;
        Integer weeksInYear = 52;
        if(jobApp.Salary__c != null && jobApp.Salary_Type__c == 'Annual'){
            annualSalary = jobApp.Salary__c;
        }
        else if (jobApp.Salary__c != null && jobApp.Salary_Type__c == 'Hourly'){
            annualSalary = (jobApp.Salary__c * weeklyHours) * weeksInYear;
        }
        else if (jobApp.Salary__c != null && jobApp.Salary_Type__c == 'Weekly'){
            annualSalary = jobApp.Salary__c * weeksInYear;
        }

        return annualSalary;
    }
}