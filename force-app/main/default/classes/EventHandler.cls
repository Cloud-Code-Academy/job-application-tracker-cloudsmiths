public with sharing class EventHandler extends TriggerHandler{
    
    private List<Event> newEvent;
    private List<Event> oldEvent;
    private Map<Id,Event> newEventMap;
    private Map<Id,Event> oldEventMap;

    public EventHandler() {

        this.newEvent = (List<Event>) Trigger.new;
        this.oldEvent = (List<Event>) Trigger.old;
        this.newEventMap = (Map<Id,Event>) Trigger.newMap;
        this.oldEventMap = (Map<Id,Event>) Trigger.oldMap;
    }

    public override void beforeInsert(){
        eventValidation(newEvent);
    }


    public static void eventValidation(List<Event> newEvent){
        /**Initializing constant for calculations, list of Owner Ids, and maps to store 
        * a lists of the Unix Epoch time for start times and end times
        **/
        final Integer MSTOSECCONVERSION = 1000;
        List<Id> ownerIdList = new List<Id>();
        Map<Id,Long> newEventStartDateEpochByEventId = new Map<Id,Long>();
        Map<Id,Long> newEventEndDateEpochByEventId = new Map<Id,Long>();
        //Iterate over each new event and populating the maps and lists
            for(Event eachEvent :newEvent){
                Long startEpochTime = eachEvent.StartDateTime.getTime()/MSTOSECCONVERSION;
                Long endEpochTime = eachEvent.EndDateTime.getTime()/MSTOSECCONVERSION;
                newEventStartDateEpochByEventId.put(eachEvent.Id,startEpochTime);
                newEventEndDateEpochByEventId.put(eachEvent.Id,endEpochTime);
                ownerIdList.add(eachEvent.OwnerId);
                //Setting variables to hold start and end day of the week and returning error if the day is a weekend
                String eventStartDay = eachEvent.StartDateTime.format('EEEE');
                String eventEndDay = eachEvent.EndDateTime.format('EEEE');
                    if(eventStartDay == 'Saturday' || eventStartDay == 'Sunday' || eventEndDay == 'Saturday' || eventEndDay == 'Sunday'){
                        eachEvent.adderror('Event cannot be scheduled on a weekend. Please select a different day.');
                    }
            }

        /**Query to find all events owned by users in the ownerIdList and initialize maps to store lists of Unix epoch start and end times
        * by Owner Id
        **/
        List<Event> allEvents = [SELECT Id, OwnerId, StartDateTime, EndDateTime FROM Event WHERE OwnerId IN :ownerIdList];
        Map<Id,List<Long>> startEpochTimeByOwnerId = new Map<Id,List<Long>>();
        Map<Id,List<Long>> endEpochTimeByOwnerId = new Map<Id,List<Long>>();
        //Iterate through allEvents list 
        for(Event eachEvent :allEvents){
            /**If start time map does not contain the OwnerId key, initialize a list of Long values, convert the start time and end time
            * to  Epoch time, add values to their respective lists, and add the key and list to the map
            **/
            if(!startEpochTimeByOwnerId.containsKey(eachEvent.OwnerId)){
                List<Long> startLong = new List<Long>();
                Long startEpochTime = eachEvent.StartDateTime.getTime()/MSTOSECCONVERSION;
                startLong.add(startEpochTime);
                startEpochTimeByOwnerId.put(eachEvent.OwnerId, startLong);
                List<Long> endLong = new List<Long>();
                Long endEpochTime = eachEvent.EndDateTime.getTime()/MSTOSECCONVERSION;
                endLong.add(endEpochTime);
                endEpochTimeByOwnerId.put(eachEvent.OwnerId, endLong);
            }
            /**
             * Get current list of start and end times, convert start and end time to Epoch time, add the value to the list and
             * update the map
             */
            else {
                List<Long> currentStartTimes = startEpochTimeByOwnerId.get(eachEvent.OwnerId);
                Long startEpochTime = eachEvent.StartDateTime.getTime()/MSTOSECCONVERSION;
                currentStartTimes.add(startEpochTime);
                startEpochTimeByOwnerId.put(eachEvent.OwnerId, currentStartTimes);
                List<Long> currentEndTimes = endEpochTimeByOwnerId.get(eachEvent.OwnerId);
                Long endEpochTime = eachEvent.EndDateTime.getTime()/MSTOSECCONVERSION;
                currentEndTimes.add(endEpochTime);
                endEpochTimeByOwnerId.put(eachEvent.OwnerId, currentEndTimes);
            }
        }

        /**Initialze Booleans to identify conflict with the Start and End times, and Strings to hold the standard format of the start
        * and end times
        **/
        for(Event eachEvent :newEvent){
            Boolean startConflict = false;
            Boolean endConflict = false;
            String standardStartTime = '';
            String standardEndTime = '';
            /**If the start time map contains the OwnerId as a key and the new Event Start and End maps contain the event Id as the key
             * create lists from the maps
             **/
            if(startEpochTimeByOwnerId.containsKey(eachEvent.OwnerId) && newEventStartDateEpochByEventId.containsKey(eachEvent.Id) && newEventEndDateEpochByEventId.containsKey(eachEvent.Id)){
                List<Long> startTimes = startEpochTimeByOwnerId.get(eachEvent.OwnerId);
                List<Long> endTimes = endEpochTimeByOwnerId.get(eachEvent.OwnerId);
                //Iterate over start time Long values
                for(Long eachStartTime :startTimes){
                    /**If value of the start time Long value is less than or equal to the new Event Long time value,
                     * set the standard time variable and update startConflict boolean to true
                     **/
                    if(eachStartTime <= newEventEndDateEpochByEventId.get(eachEvent.Id)){
                        Long startEpoch = eachStartTime * MSTOSECCONVERSION;
                        standardStartTime = Datetime.newInstance(startEpoch).format();
                        startConflict = true;
                        break;
                    }  
                }
                //Iterate over end time Long values
                for(Long eachEndTime :endTimes){
                    /**If value of the start time Long value is less than or equal to the new Event Long time value,
                     * set the standard time variable and update endConflict boolean to true
                     **/
                    if(eachEndTime >= newEventStartDateEpochByEventId.get(eachEvent.Id)){
                        Long endEpoch = eachEndTime * MSTOSECCONVERSION;
                        standardEndTime = Datetime.newInstance(endEpoch).format();
                        endConflict = true;
                        break;
                    }  
                }
                //If conflict found on both start and end dates, show error to user
                Boolean conflicts = startConflict && endConflict;
                if(conflicts){
                    eachEvent.adderror('This event starting on ' + eachEvent.StartDateTime.format() + ' and ending on ' + eachEvent.EndDateTime.format() + ' overlaps with another event starting on ' + standardStartTime + ' and ending on ' + standardEndTime + '. Please select a new time.');
                }
            }
        }
        
    }

}