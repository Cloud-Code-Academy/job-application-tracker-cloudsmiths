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
        
        final Integer MSTOSECCONVERSION = 1000;
        List<Id> ownerIdList = new List<Id>();
        List<Id> newEventIdList = new List<Id>();
        Map<Id,Long> newEventStartDateEpochByEventId = new Map<Id,Long>();
        Map<Id,Long> newEventEndDateEpochByEventId = new Map<Id,Long>();
            for(Event eachEvent :newEvent){
                Long startEpochTime = eachEvent.StartDateTime.getTime()/MSTOSECCONVERSION;
                Long endEpochTime = eachEvent.EndDateTime.getTime()/MSTOSECCONVERSION;
                newEventStartDateEpochByEventId.put(eachEvent.Id,startEpochTime);
                newEventEndDateEpochByEventId.put(eachEvent.Id,endEpochTime);
                ownerIdList.add(eachEvent.OwnerId);
                newEventIdList.add(eachEvent.Id);
                String eventStartDay = eachEvent.StartDateTime.format('EEEE');
                String eventEndDay = eachEvent.EndDateTime.format('EEEE');
                    if(eventStartDay == 'Saturday' || eventStartDay == 'Sunday' || eventEndDay == 'Saturday' || eventEndDay == 'Sunday'){
                        eachEvent.adderror('Event cannot be scheduled on a weekend. Please select a different day.');
                    }
            }

        List<Event> allEvents = [SELECT Id, OwnerId, StartDateTime, EndDateTime FROM Event WHERE OwnerId IN :ownerIdList AND Id NOT IN :newEventIdList];
        Map<Id,List<Long>> startEpochTimeByOwnerId = new Map<Id,List<Long>>();
        Map<Id,List<Long>> endEpochTimeByOwnerId = new Map<Id,List<Long>>();
        for(Event eachEvent :allEvents){
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
            System.debug('Start Time Map ' + startEpochTimeByOwnerId);
        }

        for(Event eachEvent :newEvent){
            Boolean conflictFound = false;
            Boolean startConflict = false;
            Boolean endConflict = false;
            String standardStartTime = '';
            String standardEndTime = '';
            if(startEpochTimeByOwnerId.containsKey(eachEvent.OwnerId) && newEventStartDateEpochByEventId.containsKey(eachEvent.Id) && newEventEndDateEpochByEventId.containsKey(eachEvent.Id)){
                List<Long> startTimes = startEpochTimeByOwnerId.get(eachEvent.OwnerId);
                List<Long> endTimes = endEpochTimeByOwnerId.get(eachEvent.OwnerId);
                for(Long eachStartTime :startTimes){
                    System.debug('Old Event Start ' + eachStartTime);
                    System.debug('New Event Start ' + newEventEndDateEpochByEventId.get(eachEvent.Id));
                    if(eachStartTime <= newEventEndDateEpochByEventId.get(eachEvent.Id)){
                        Long startEpoch = eachStartTime * MSTOSECCONVERSION;
                        standardStartTime = Datetime.newInstance(startEpoch).format();
                        startConflict = true;
                        break;
                    }  
                }
                for(Long eachEndTime :endTimes){
                    System.debug('Old Event Start ' + eachEndTime);
                    System.debug('New Event Start ' + newEventStartDateEpochByEventId.get(eachEvent.Id));
                    if(eachEndTime >= newEventStartDateEpochByEventId.get(eachEvent.Id)){
                        Long endEpoch = eachEndTime * MSTOSECCONVERSION;
                        standardEndTime = Datetime.newInstance(endEpoch).format();
                        endConflict = true;
                        break;
                    }  
                }
                if(startConflict && endConflict){
                    eachEvent.adderror('This event starting on ' + eachEvent.StartDateTime.format() + ' and ending on ' + eachEvent.EndDateTime.format() + ' overlaps with another event starting on ' + standardStartTime + ' and ending on ' + standardEndTime + '. Please select a new time.');
                }
            }
        }
        
    }

}