/**
 * @description       : InvocableMethod that executes the JoobleCallout
 * @author            : Riley Meyer
 * @group             : Cloud Smiths
 * @last modified on  : 08-02-2024
 * @last modified by  : Riley Meyer
**/
public class CreateJoobleCalloutBodyAction {
    // This method is invoked from the Jooble Search screen flow
    @InvocableMethod(callout=true label='Create Jooble Callout Body' category='Job Application' description='Creates the body that will be used in the callout to Jooble')
    public static void createJoobleCalloutBody(List<FlowInput> inputs){
        for (FlowInput input : inputs) {
            JoobleCallout.getJobsFromJooble(input);
        }
    }

    public class FlowInput{
        @InvocableVariable(label='Keywords' Description='Keywords to search for jobs.' placeholderText='Salesforce Developer' required=true)
        public String keywords;
        @InvocableVariable(label='Location' Description='Location to search for jobs.' placeholderText='Omaha, NE' required=true)
        public String location;
        @InvocableVariable(label='Date Created From' Description='Get jobs created after this date.' placeholderText='yyyy-mm-dd' required=true)
        public String dateCreatedFrom;
        @InvocableVariable(label='Salary' Description='Minimum salary for the job search.' placeholderText='100000' required=true)
        public String salary;
        
    }
}