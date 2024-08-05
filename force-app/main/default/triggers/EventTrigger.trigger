/**
 * @description       : Trigger for Event object. Runs on before insert
 * @author            : Tyler Riden
 * @group             : Cloud Smiths
 * @last modified on  : 08-01-2024
 * @last modified by  : Tyler Riden
**/
trigger EventTrigger on Event (before insert) {
    EventHandler handler = new EventHandler();
    handler.run();
}