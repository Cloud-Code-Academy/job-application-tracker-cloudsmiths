import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import JOB_APPLICATION_OBJECT from "@salesforce/schema/Job_Application__c";
import COMPANY_FIELD from "@salesforce/schema/Job_Application__c.Company__c";
import PRIMARY_CONTACT_FIELD from "@salesforce/schema/Job_Application__c.Primary_Contact__c";
import STATUS_FIELD from "@salesforce/schema/Job_Application__c.Status__c";
import POSITION_TITLE_FIELD from "@salesforce/schema/Job_Application__c.Position_Title__c";
import SALARY_FIELD from "@salesforce/schema/Job_Application__c.Salary__c";
import SALARY_TYPE_FIELD from "@salesforce/schema/Job_Application__c.Salary_Type__c";
/**
 * Creates Job Application record.
 */
export default class JobApplicationCreator extends NavigationMixin(LightningElement){
  jobAppObject = JOB_APPLICATION_OBJECT;
  myFields = [COMPANY_FIELD, PRIMARY_CONTACT_FIELD,STATUS_FIELD,POSITION_TITLE_FIELD,SALARY_FIELD,SALARY_TYPE_FIELD];

  handleSuccess(event) {
    const recordId = event.detail.id;
    
    // Use the NavigationMixin to navigate to the newly created record page
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: 'Job_Application__c', // Object API name
            actionName: 'view'
          }
      });
  }

}