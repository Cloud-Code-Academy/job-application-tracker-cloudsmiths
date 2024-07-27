// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// string tempvar = 'Enter_your_name_here';
// System.debug('Hello World!');
// System.debug('My name is ' + tempvar);

// Datetime now = Datetime.now();
// System.debug(now);

// Account acc = new Account();
// try{
//     insert acc;
// }
// catch(Exception e){
//     System.debug(e);
// }

// Boolean startConflict = true;
// Boolean endConflict = true;
// Boolean conflict = startConflict && endConflict;
// System.debug(conflict);

List<Hiring_Team__c> hiringTeamList = HiringTeamController.getHiringTeamList('a00ak00000EsOF0AAN');
System.debug(hiringTeamList);
