/**
 * @description       : Generates a successful response for testing the Jooble API
 * @author            : Riley Meyer
 * @group             : Cloud Smiths
 * @last modified on  : 08-02-2024
 * @last modified by  : Riley Meyer
**/
global class JoobleCalloutMockGenerator implements HttpCalloutMock {
    // Mocks a JSON response from the Jooble API
    public static String JOOBLE_JSON_JOBS_PAYLOAD = '{'
    + '"totalCount": 1676,'
    + '"jobs": ['
        + '{'
            + '"title": "Salesforce Developer(Relocation to India) - Virtual/Remote",'
            + '"location": "Bellevue, NE",'
            + '"snippet": "&nbsp;...As part of the Client\'s team, as a <b>Salesforce Developer </b>your primary role would be to actively aid the consulting team in different phases of the project including problem definition, effort estimation, diagnosis, solution generation and design and deployment Benefits...&nbsp;",'
            + '"salary": "$180k",'
            + '"source": "career.place",'
            + '"type": "Full-time",'
            + '"link": "https://jooble.org/desc/4352497110792274330?ckey=Salesforce+Developer&rgn=28768&pos=1&groupId=40906&elckey=-4116763012177270465&p=1&aq=3490550690369373625&cid=3567&jobAge=18&relb=100&brelb=100&bscr=4678.32&scr=4678.32",'
            + '"company": "DNI Talents Inc",'
            + '"updated": "2024-07-28T00:00:00.0000000",'
            + '"id": 4352497110792274330'
        + '},'
        + '{'
            + '"title": "Database Developer",'
            + '"location": "Omaha, NE",'
            + '"snippet": "&nbsp;...JOB TITLE:  Database <b>Developer </b> LOCATION DETAILS: Hybrid, onsite Tues, Wed, Thrs. Remote Monday/Friday. COVID/VACCINATION...&nbsp;&nbsp;...working with business Take data and push to Snowflake or <b>Salesforce </b>etc. Don t use SSIS Employers have access to...&nbsp;",'
            + '"salary": "$180k - $250k",'
            + '"source": "jobs.institutedata.com",'
            + '"type": "Temporary",'
            + '"link": "https://jooble.org/desc/-7235358679435661080?ckey=Salesforce+Developer&rgn=28768&pos=2&groupId=40906&elckey=-4116763012177270465&p=1&aq=3490550690369373625&cid=3567&jobAge=402&relb=100&brelb=100&bscr=3563.459&scr=3563.459",'
            + '"company": "Arcon Solutions Inc",'
            + '"updated": "2024-07-12T02:19:47.9837898+00:00",'
            + '"id": -7235358679435661080'
        + '},'
        + '{'
            + '"title": ".Net Developer",'
            + '"location": "Omaha, NE",'
            + '"snippet": "&nbsp;...Job Description Job Description  .Net <b>Developer </b>12 Months Contract Location 4642 S 132nd Street, Omaha, NE 68137 ( Hybrid - 2 days a week Mon and Wed) $40 /hr. W2 Skills: Minimum Years of Experience:  Less than 1 year Understand Company policies...&nbsp;",'
            + '"salary": "$18 - $25 per hour",'
            + '"source": "ziprecruiter.com",'
            + '"type": "Part-time",'
            + '"link": "https://jooble.org/desc/-8109038760780624950?ckey=Salesforce+Developer&rgn=28768&pos=3&groupId=40906&elckey=-4116763012177270465&p=1&aq=3490550690369373625&cid=3567&jobAge=234&relb=115&brelb=115&bscr=3548.5608&scr=3548.5608",'
            + '"company": "Pride Health",'
            + '"updated": "2024-07-19T00:00:00.0000000",'
            + '"id": -8109038760780624950'
        + '},'
        + '{'
            + '"title": "Lead Developer",'
            + '"location": "Omaha, NE",'
            + '"snippet": "&nbsp;...Job Description Job Description  Lead <b>Developer </b>(.Net/C#) needed to fill a new position for a well-respected client located in Omaha, Nebraska. Apply today to take advantage of this unique and exciting opportunity! WHAT IS GREAT ABOUT THIS OPPORTUNITY?~ DIRECT HIRE...&nbsp;",'
            + '"salary": "$60 per hour",'
            + '"source": "ziprecruiter.com",'
            + '"type": "Contract",'
            + '"link": "https://jooble.org/desc/-4092181985765816191?ckey=Salesforce+Developer&rgn=28768&pos=4&groupId=40906&elckey=-4116763012177270465&p=1&aq=3490550690369373625&cid=3567&jobAge=282&relb=115&brelb=115&bscr=3494.914&scr=3494.914",'
            + '"company": "The Reserves Network Inc",'
            + '"updated": "2024-07-17T00:00:00.0000000",'
            + '"id": -4092181985765816191'
        + '},'
        + '{'
            + '"title": "Senior Java Developer",'
            + '"location": "Omaha, NE",'
            + '"snippet": "&nbsp;...Job Description Job Description  Technology\'s Future Depends On Innovators! Senior Java <b>Developer </b> We are seeking a Senior Software Java Engineer with at least 6 years of experience to design, develop, and implement software solutions using Agile Scrum methodologies...&nbsp;",'
            + '"salary": "$2,124 per week",'
            + '"source": "ziprecruiter.com",'
            + '"type": "",'
            + '"link": "https://jooble.org/desc/2411371613022444342?ckey=Salesforce+Developer&rgn=28768&pos=5&groupId=40906&elckey=-4116763012177270465&p=1&aq=3490550690369373625&cid=3567&jobAge=66&relb=115&brelb=115&bscr=3486.0806&scr=3486.0806",'
            + '"company": "Cordova",'
            + '"updated": "2024-07-26T00:00:00.0000000",'
            + '"id": 2411371613022444342'
        + '}'
    + ']'
+ '}';

    global HTTPResponse respond(HTTPRequest req) {
		// Create a response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		// Return a success response for the POST request
		if (req.getMethod() == 'POST') {
			res.setBody(JOOBLE_JSON_JOBS_PAYLOAD);
            res.setStatusCode(200);
            res.setStatus('OK');
		}
		return res;
	}
}