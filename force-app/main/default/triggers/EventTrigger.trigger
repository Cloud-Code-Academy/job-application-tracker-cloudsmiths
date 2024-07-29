trigger EventTrigger on Event (before insert) {

    EventHandler handler = new EventHandler();
    handler.run();
    
}