/**
 * @description       : Handler for Job Application trigger
 * @author            : Tyler Riden
 * @group             : Cloud Smiths
 * @last modified on  : 08-01-2024
 * @last modified by  : Tyler Riden
**/
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
        taxWithholdingCalculator(newJobApplications);
        deductionUpdatesAndValidations(newJobApplications);
    }

    public override void afterInsert(){
        List<Hiring_Team__c> hiringTeamList = createMissingHiringTeam(newJobApplications);
        TriggerHandler.bypass('HiringTeamHandler');
        Database.insert (hiringTeamList, AccessLevel.SYSTEM_MODE);
        TriggerHandler.clearAllBypasses();
        //Method to create Tasks for the Job Application record based on the Status of the Application
        JobApplicationStatusHelper.tasksBasedOnStatus(newJobApplications, oldJobApplicationMap);
    }

    public override void beforeUpdate(){
        taxWithholdingCalculator(newJobApplications);
        deductionUpdatesAndValidations(newJobApplications);
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
        for(Job_Application__c jobApp :newJobApplications){
            if(jobApp.Tax_Filing_Status__c != null){
                filingStatus.add(jobApp.Tax_Filing_Status__c);
            }
        }
        //Get Tax rate data, set rate variables, initialize, and populate map of Standard Deductions
        List<Tax_Withholding__mdt> taxMetadata = [SELECT Id, Tax_Rate__c, Type__c, Filing_Status__c, Minimum_Amount__c, Maximum_Amount__c 
                                                FROM Tax_Withholding__mdt
                                                Order By Tax_Rate__c ASC];
        List<Tax_Withholding__mdt> federalTaxRates = new List<Tax_Withholding__mdt>();
        Tax_Withholding__mdt socialSecurityRateRecord = new Tax_Withholding__mdt();
        Tax_Withholding__mdt medicareRateRecord =  new Tax_Withholding__mdt();
        List<Tax_Withholding__mdt> standardDeductionsList = new List<Tax_Withholding__mdt>();
        for(Tax_Withholding__mdt taxRate :taxMetadata){
            if(taxRate.Type__c == 'Federal Income' && filingStatus.contains(taxRate.Filing_Status__c)){
                federalTaxRates.add(taxRate);
            }
            if(taxRate.Type__c == 'Standard Deduction'){
                standardDeductionsList.add(taxRate);
            }
            if(taxRate.Type__c == 'Social Security'){
                socialSecurityRateRecord = taxRate;
            }
            if(taxRate.Type__c == 'Medicare'){
                medicareRateRecord = taxRate;
            }
        }
    
        //Create and assign new variables for calculations 
        Decimal federalTaxRate = 0;
        Decimal medicareTaxRate = 0;
        Decimal standardDeductions = 0;
        Decimal salaryAmount = 0;
        Decimal federalTaxWithheld = 0;
        Decimal socialSecurityRate = socialSecurityRateRecord.Tax_Rate__c / 100;
        Decimal socialSecurityCap = socialSecurityRateRecord.Maximum_Amount__c;
        Decimal medicareRate = medicareRateRecord.Tax_Rate__c / 100;
        Decimal medicareCap = medicareRateRecord.Maximum_Amount__c;
        Map<String,Decimal> standardDeductionByFilingStatusMap = new Map<String,Decimal>();
        for(Tax_Withholding__mdt deduction :standardDeductionsList){
            if(!standardDeductionByFilingStatusMap.containsKey(deduction.Filing_Status__c)){
                standardDeductionByFilingStatusMap.put(deduction.Filing_Status__c,deduction.Maximum_Amount__c);
            }
        }

        //Initial map of Job Applications By Id and populate the map
        Map<Id,Job_Application__c> jobApplictionByIdMap = new Map<Id,Job_Application__c>();
        for(Job_Application__c jobApp :newJobApplications){
            if(!jobApplictionByIdMap.containsKey(jobApp.Id)){
                jobApplictionByIdMap.put(jobApp.Id, jobApp);
            }
        }

        //Iterate through Job Applictions and perform calculations
        for(Job_Application__c jobApp :newJobApplications){
            //If Tax Filing Status, or Salary is null or Salary is 0, set withholding fields to 0
            if(jobApp.Tax_Filing_Status__c == null || jobApp.Salary__c == null || jobApp.Salary__c == 0){
                jobApp.Federal_Income_Tax_Withheld__c = 0;
                jobApp.Medicare_Withheld__c = 0;
                jobApp.Social_Security_Withheld__c = 0;
                jobApp.Take_Home_Amount__c = 0;
                continue;
            }
            //Create and assign additional variables for calculations
            Integer monthsInYear = 12;
            Decimal taxableIncome = 0;
            Decimal socialSecurityWithheld = 0;
            Decimal medicareWithheld = 0;
            Decimal annualSalary = annualSalaryCalculator(jobApp);
            //Calculate taxable income based on deductions and calculate Social Security and Medicare withholdings
            if(jobApp.Deduction_Type__c == 'Standard Deduction' && standardDeductionByFilingStatusMap.containsKey(jobApp.Tax_Filing_Status__c)){
                taxableIncome = annualSalary - standardDeductionByFilingStatusMap.get(jobApp.Tax_Filing_Status__c);
            }
            else if(jobApp.Deduction_Type__c == 'Itemized Deduction' && jobApp.Itemized_Deduction_Amount__c != null){
                taxableIncome = annualSalary - jobApp.Itemized_Deduction_Amount__c;
            }
            else{
                taxableIncome = annualSalary;
            }
            if((socialSecurityCap != null && taxableIncome < socialSecurityCap) || socialSecurityCap == null){
                socialSecurityWithheld = taxableIncome * socialSecurityRate;
            }
            else if(socialSecurityCap != null && taxableIncome >= socialSecurityCap){
                socialSecurityWithheld = socialSecurityCap * socialSecurityRate;
            }
            if((medicareCap != null && taxableIncome < medicareCap) || medicareCap == null){
                medicareWithheld = taxableIncome * medicareRate;
            }
            /**
             * Can uncomment if needed. Accounts for cap on Medicare taxes, which currently don't exist
            else if(medicareCap != null && taxableIncome >= medicareCap){
                medicareWithheld = medicareCap * medicareRate;
            }
            **/
            //Assign variables for calculations
            Decimal fedTaxWithheld = 0;
            Decimal remainingSalary = annualSalary;
            Decimal amountTaxed = 0;
            //Iterate over tax rates from metadata and compare to calculate variables to determine taxes withheld
            for(Tax_Withholding__mdt taxRate :federalTaxRates){
                Decimal rate = taxRate.Tax_Rate__c / 100;
                if(taxRate.Filing_Status__c == jobApp.Tax_Filing_Status__c && taxableIncome != null && taxableIncome >= taxRate.Minimum_Amount__c && taxableIncome <= taxRate.Maximum_Amount__c && taxRate.Maximum_Amount__c != null && (taxableIncome - amountTaxed) > 0){
                    fedTaxWithheld += (taxableIncome - amountTaxed) * rate;
                    remainingSalary =  taxableIncome - fedTaxWithheld;
                    amountTaxed = remainingSalary - fedTaxWithheld;
                }
                else if(taxRate.Filing_Status__c == jobApp.Tax_Filing_Status__c && annualSalary != null && taxableIncome >= taxRate.Minimum_Amount__c && taxableIncome > taxRate.Maximum_Amount__c){
                    fedTaxWithheld += (taxRate.Maximum_Amount__c - taxRate.Minimum_Amount__c) * rate;
                    remainingSalary = taxableIncome - (taxRate.Maximum_Amount__c - taxRate.Minimum_Amount__c);
                    amountTaxed += (taxRate.Maximum_Amount__c - taxRate.Minimum_Amount__c);
                }
                else if(taxRate.Filing_Status__c == jobApp.Tax_Filing_Status__c && taxableIncome != null && taxRate.Maximum_Amount__c == null && taxableIncome >= taxRate.Minimum_Amount__c && (taxableIncome - amountTaxed) > 0){
                    fedTaxWithheld += (taxableIncome - taxRate.Minimum_Amount__c) * rate;
                    remainingSalary = annualSalary - fedTaxWithheld;
                    amountTaxed = remainingSalary - fedTaxWithheld;
                }
            }
            //Assign fields on the job application to calculated values
            jobApp.Federal_Income_Tax_Withheld__c = fedTaxWithheld;
            jobApp.Medicare_Withheld__c = medicareWithheld;
            jobApp.Social_Security_Withheld__c = socialSecurityWithheld;
            jobApp.Take_Home_Amount__c = annualSalary - (fedTaxWithheld + medicareWithheld + socialSecurityWithheld);
            jobApp.Monthly_Federal_Income_Tax_Withheld__c = fedTaxWithheld / monthsInYear;
            jobApp.Monthly_Medicare_Withheld__c = medicareWithheld / monthsInYear;
            jobApp.Monthly_Social_Security_Withheld__c = socialSecurityWithheld / monthsInYear;
            jobApp.Monthly_Take_Home_Amount__c = ((annualSalary - (fedTaxWithheld + medicareWithheld + socialSecurityWithheld)) / monthsInYear);
            if(jobApp.Deduction_Type__c == 'Standard Deduction' && standardDeductionByFilingStatusMap.containsKey(jobApp.Tax_Filing_Status__c)){
                jobApp.Standard_Deduction__c = standardDeductionByFilingStatusMap.get(jobApp.Tax_Filing_Status__c);
            }
        }
    }

    public static Decimal annualSalaryCalculator(Job_Application__c jobApp){
        //Method used to convert hourly or weekly salary to annual amount
        Decimal annualSalary = 0;
        Integer weeklyHours = 40;
        Integer weeksInYear = 52;
        if(jobApp.Salary__c != null && jobApp.Salary_Type__c == 'Annual'){
            annualSalary = jobApp.Salary__c;
        }
        else if (jobApp.Salary__c != null && jobApp.Salary_Type__c == 'Hourly'){
            annualSalary = ((jobApp.Salary__c * weeklyHours) * weeksInYear);
        }
        else if (jobApp.Salary__c != null && jobApp.Salary_Type__c == 'Weekly'){
            annualSalary = (jobApp.Salary__c * weeksInYear);
        }

        return annualSalary;
    }

    public static void deductionUpdatesAndValidations(List<Job_Application__c> newJobApplicationMap){
        for(Job_Application__c jobApp :newJobApplicationMap){
            //Sets Itemized Deduction Amount to null if Deduction Type is Standard Deduction
            if(jobApp.Deduction_Type__c == 'Standard Deduction' && jobApp.Itemized_Deduction_Amount__c != null){
                jobApp.Itemized_Deduction_Amount__c = null;
            }
            //Sets Standard Deduction to null if Deduction Type is Itemized Deduction
            if(jobApp.Deduction_Type__c == 'Itemized Deduction' && jobApp.Standard_Deduction__c != null){
                jobApp.Standard_Deduction__c = null;
            }
            //Sets both Standard and Itemized Deduction Amount to null if Deduction Type is null
            if((jobApp.Deduction_Type__c == null || jobApp.Deduction_Type__c == 'None') && (jobApp.Standard_Deduction__c != null || jobApp.Itemized_Deduction_Amount__c != null)){
                jobApp.Standard_Deduction__c = null;
                jobApp.Itemized_Deduction_Amount__c = null;
            }
            //Validation to ensure Itemized Deduction Amount is populated if Deduction Type is Itemized Deduction
            if(jobApp.Deduction_Type__c == 'Itemized Deduction' && jobApp.Itemized_Deduction_Amount__c == null){
                jobApp.addError('If Itemized Deduction is selected, the Itemized Deduction Amount must be provided');
            }
            //Validation to ensure Salary is positive
            if(jobApp.Salary__c < 0){
                jobApp.addError('You cannot enter a negative salary');
            }
        }
    }
}