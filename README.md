# HOW TO GRANT ACCESS TO THE JOB APPLICATION APP
The 'Job Application Permission Set' provides Users with access to the Job Application app once installed.

Named credentials are used to store the endpoint and the Access Token for the JoobleAPI which users are granted access to via this Permission Set.

# SEARCHING FOR JOBS
The Jooble Search Flow is installed as a part of the package and is added to the Job Application app Homepage. This Flow calls the CreateJoobleCalloutBodyAction invocable method which then makes the call to Jooble to retrieve Job Application records.

You can filter on the following:

- Keywords (searched in the job title and description)
- Location
- Salary (minimum salary)
- Date Created From (jobs created after this date)


# INTERVIEW REMINDER
The InterviewReminder class is used to remind Interviewees via email the day before an interview is scheduled.

It is  recommended that you schedule this class to run nightly at 1 A.M.

You can run these lines of code in Developer Console > Apex Anonymous to schedule this Class to run nightly at 1 A.M.
 
InterviewReminder i = new InterviewReminder();<br/>
String sch = '0 0 1 * * ?';<br/>
String jobID = System.schedule('Interview Reminder', sch, i);<br/>
System.debug(jobID);<br/>


# STALE JOB APPLICATION CLEANUP
The StaleJobApplicationProcess class is used to cleanup stale Job Application records in the system. A Job Application is considered stale if one of the two following criteria are met:

1. The Status is not equal to 'Closed' or 'Accepted' and the Follow Up Date is more than 30 days ago.
2. The Status is not equal to 'Closed' or 'Accepted' and the Follow Up Date is null and the Created Date is more than 30 days ago.

It is  recommended that you schedule this class to run nightly at 1 A.M.

You can run these lines of code in Developer Console > Apex Anonymous to schedule this Class to run nightly at 1 A.M.

StaleJobApplicationProcess i = new StaleJobApplicationProcess();<br/>
String sch = '0 0 1 * * ?';<br/>
String jobID = System.schedule('Stale JobApp Process', sch, i);<br/>
System.debug(jobID);<br/>
