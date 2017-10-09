//
//  EventOrganizer.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/26/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
/* Class that will be instantiated into the GameScene where physics
events will be enlisted. This class will allow the user to set
specific events that will stall the game scene when they happen;
it will communicate with the game scene so that the game scene may
know when exactly objects collide into other objects, and other
events that occur. */


import Foundation

class EventOrganizer: NSObject {
    var eventContactDelegate: EventOrganizerContactDelegate! = nil;
    var event: Event!;  // The event that we will be analyzing.
    var scene: GameScene;
    
    // This function is called by the event. This is what happens
    // when an event condition is actually executed.
    func triggerEvent(event: Event) {
        if (event != self.event) { return }
        
        // The event that happened is a collision event!
        if (event.isCollisionEvent()) {
            // Event is collision so it should have both sprites!
            scene.eventTriggered(event)
        }
        else if (event.isTimerEvent()) { scene.eventTriggered(event) }
        else if (event.isPropertyEvent()) { scene.eventTriggered(event) }
    }
    
    // Checks if the parameter event has been triggered.
    func checkParameterEventTriggered() {
        if (event == nil) { return; }
        event.checkParameters();
    }
    
    // Creates a collision event. If these two objects ever collide, then
    // the gamescene eventTriggered function will be called.
    // The game scene handles the rest.
    func createCollisionEvent(sprite1: PWObject, sprite2: PWObject) {
        if (self.event != nil) { deleteEvent() }
        let event = Event.createCollision(self, sprite1: sprite1, sprite2: sprite2)
        
        if (event == nil) { return };
        print("Created collision event");
        
        self.event = event!
        eventContactDelegate.setCollisionEvent(event!);
    }
    
    // Creates a time event. In the specified time frame AFTER starting the simulation,
    // the eventTriggered function gets called in game scene.
    func createTimeEvent(time: CGFloat) {
        if (self.event != nil) { deleteEvent() }
        print("Created timer event");
        event = Event.createTime(self, time: time)
    }
    
    func pauseEventTimer() {
        if (self.event == nil) { return }
        if (!self.event.isTimerEvent()) { return }
        if (self.event.hasHappened()) { return }
        
        self.event.stopTimer()
    }
    
    func resumeEventTimer() {
        if (self.event == nil) { return }
        if (!self.event.isTimerEvent()) { return }
        if (self.event.hasHappened()) { return }
        
        self.event.resumeTimer()
    }
    
    
    // Creates a parameter-driven event. This is a kind of event that
    // checks when a specific parameter of a PWObject exceeds a given value.
    // The available event types are defined in the struct in Event.swift.
    func createParameterEvent(sprite: PWObject, flag: Int, value: CGFloat)
    {
        if (self.event != nil) { deleteEvent() }
        print("Created parameter event");
        event = Event.createParameter(self, sprite: sprite, parameterFlag: flag, limitValue: value)
        event.setOriginPoint(sprite.position);
    }
    
    
    // Deletes the current event.
    func deleteEvent() -> Event! {
        if (event == nil) { return nil; }
        let prev = event;
        
        event = nil;
        
        return prev;
    }
    
    func hasEventOccurred() -> Bool { return event.hasHappened() }
    
    // Does this module have an event relating with it
    func containsEvent() -> Bool { return (event != nil) }
    
    // Creates Event Organizer object and initializes
    // the contact delegate in preparation for the events.
    required init(gamescene: GameScene) {
        scene = gamescene;
        super.init();
        eventContactDelegate = EventOrganizerContactDelegate.init(eo: self);
        gamescene.physicsWorld.contactDelegate = eventContactDelegate;
    }
}