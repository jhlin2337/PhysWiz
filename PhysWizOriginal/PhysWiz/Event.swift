//
//  Event.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/26/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
//  An Event object that will be used by the Event Organizer.
//  Every event that is created will instantiate this event object.
//  This object can either be a time element, a contact element,
//  or a property element. It will be used to trigger conditions
//  that the user sets.
//  There are three types of events:
//  Collision - Any type of collision between two objects.
//  Time      - Any type of event that relies on time passing by.
//  Property  - Any type of event that requires checking sprite properties (Velocity, acceleration, etc)

import Foundation

// The types of parameters to be found within the object.
// This is ONLY used when the event is of type parameter.
struct event_PropertyType {
    static let UNKNOWN  = -1;
    static let distance = 0;
    static let height   = 1;
    static let vel_x    = 2;
    static let vel_y    = 3;
    static let ang_vel  = 4;
    static let acc_x    = 5;
    static let acc_y    = 6;
}

class Event: NSObject {
    private var isCollision                     = false;
    private var isTime                          = false;
    private var isProperty                      = false;
    private var alive                           = true;  // Is the event still being checked?
    private var eventorganizer: EventOrganizer
    
    ////////////////////////////////////////////////////////////
    //////////////// Collision Variables ///////////////////////
    ////////////////////////////////////////////////////////////
    private var sprite1: PWObject! = nil; // Also used for time and Properties
    private var sprite2: PWObject! = nil;
    private var initialPropertyValue = CGFloat(0);
    
    ////////////////////////////////////////////////////////////
    //////////////// Time Variables ////////////////////////////
    ////////////////////////////////////////////////////////////
    private var time: CGFloat!              = nil;
    private var timer: NSTimer!             = nil;
    private var gameTimePassed: CGFloat     = 0; // The total in game time passed with timer.
    
    ////////////////////////////////////////////////////////////
    //////////////// Parameter Variables ///////////////////////
    ////////////////////////////////////////////////////////////
    private var parameterFlag                       = event_PropertyType.UNKNOWN; // Defined in the top
    private var parameterLimit                      = CGFloat.infinity;
    private var dispatchWorker: NSOperationQueue!   = nil; // Worker that checks parameters.
    private var originPoint: CGPoint!               = nil; // The point that the distance is gonna be compared to.
    
    
    // Has the event already been executed?
    func hasHappened() -> Bool { return !self.alive; }
    func setHappened() { self.alive = false; }
    
    ////////////////////////////////////////////////////////////
    //////////////// Collision Parameters //////////////////////
    ////////////////////////////////////////////////////////////
    
    // Returns the sprites of the event. If it's not collision event,
    // then it returns nothing.
    func getSprites() -> [PWObject]? {
        if (!isCollision) { return nil; }
        return [sprite1, sprite2];
    }
    func setSprites(sprite1: PWObject, sprite2: PWObject) {
        if (!isCollision) { return; }
        self.sprite1 = sprite1;
        self.sprite2 = sprite2;
    }
    
    func isCollisionEvent() -> Bool { return self.isCollision }
    
    // This function is called by the Contact Delegate to check if
    // collision matches with the event. It is called pretty constantly.
    func checkAndTriggerCollision(sprite1: PWObject, sprite2: PWObject)
    {
        if (!self.isCollisionEvent()) { return; }
        
        let eventSprites = self.getSprites();
        if (eventSprites?.count != 2) { return; }
        
        
        if (!(eventSprites?.contains(sprite1))!) { return; }
        if (!(eventSprites?.contains(sprite2))!) { return; }
        
        // Collision matches with event!
        self.setHappened();
        eventorganizer.triggerEvent(self);
    }
    
    
    ////////////////////////////////////////////////////////////
    //////////////// Time Parameters ///////////////////////////
    ////////////////////////////////////////////////////////////
    
    func isTimerEvent() -> Bool { return self.isTime }
    
    // Gets the upper bound of the timer
    func getMaxTime() -> CGFloat? {
        if (!isTime) { return nil; }
        return time;
    }
    
    func getCurrentTime() -> CGFloat? {
        if (!isTime) { return nil; }
        return gameTimePassed;
    }
    
    func setTime(time: CGFloat) {
        if (!isTime) { return }
        self.time = time;
    }
    
    func resumeTimer() {
        if (!isTime) { return }
        if (self.timer == nil) { return }
        if (self.time <= gameTimePassed) { return }
        let prevTime = self.time
        initTimer(self.time - gameTimePassed);
        print("Timer resumed! " + String(self.time-gameTimePassed) + " seconds remaining" );
        self.setTime(prevTime);
    }
    
    func stopTimer() {
        if (!isTime) { return }
        if (self.timer == nil) { return };
        print("Timer stopped! " + String(self.timer.timeInterval) + " seconds remaining" );
        self.timer.invalidate();
    }
    
    func initTimer(time: CGFloat) {
        self.setTime(time);
        self.timer = NSTimer.scheduledTimerWithTimeInterval(Double(time), target: self, selector: "triggerTimer", userInfo: nil, repeats: true);
    }
    
    func triggerTimer() {
        eventorganizer.triggerEvent(self);
        NSLog("Timer triggered!");
        self.setHappened();
        self.stopTimer();
    }
    
    ////////////////////////////////////////////////////////////
    //////////////// PWObject Properties ///////////////////////
    ////////////////////////////////////////////////////////////
    func isPropertyEvent() -> Bool { return self.isProperty }
    
    // Creates the dispatch worker that will check the event properties.
    // The reason why I choose to use NSOperationQueue is so that
    // we take advantage of concurrency. This will hopefully not bog
    // down the interface in using this approach.
    func dispatchPropertyChecker() {
        if (self.dispatchWorker != nil) { return }
        
        self.dispatchWorker = NSOperationQueue()
        
        let checkLimit : NSBlockOperation = NSBlockOperation (block: {
            while (true) {
                // Do all the checking in here
                if (self.checkGreaterThanLimit()) {
                    self.setHappened();
                    self.eventorganizer.triggerEvent(self);
                    return;
                }
            }
        })
        
        self.dispatchWorker.addOperation(checkLimit)
        
    }
    
    // Checks if the parameters of these events exceed the limit.
    // If so, it has been triggered.
    func checkParameters() {
        if (!self.isPropertyEvent()) { return }
        
        if (self.checkGreaterThanLimit()) {
            self.setHappened();
            self.eventorganizer.triggerEvent(self);
            return;
        }
    }
    
    // Returns the value set by the properties that this event
    // is trying to find. Returns -1 if event is improperly
    // initialized.
    func getCurrentPropertyValue() -> CGFloat {
        if (!self.isProperty) { return -1; }
        if (self.parameterFlag == -1) { return -1; }
        let sprite = sprite1;
        
        switch parameterFlag {
        case event_PropertyType.height:
            return sprite.getPos().y
            
        case event_PropertyType.distance:
            return sprite.distanceToPoint(self.originPoint);
            
        case event_PropertyType.vel_x:
            return sprite.getVelocity().dx;
            
        case event_PropertyType.vel_y:
            return sprite.getVelocity().dy;
            
        case event_PropertyType.ang_vel:
            return sprite.getAngularVelocity();
            
        case event_PropertyType.acc_x:
            return sprite.getAcceleration().dx;
            
        case event_PropertyType.acc_y:
            return sprite.getAcceleration().dy;
            
        default:
            return -1;
        };
    }
    
    // Does the current property value exceed its limit
    func checkGreaterThanLimit() -> Bool {
        let currentVal = getCurrentPropertyValue();
        if self.initialPropertyValue < self.parameterLimit {
        return currentVal >= self.parameterLimit
        }
        else if self.initialPropertyValue > self.parameterLimit {
        return currentVal <= self.parameterLimit
        }
        else {
         return true
        }
    }
    
    // When this function is called, make sure you input
    // the flags based on the struct defined above!
    // This function doesn't check for invalid flags.
    func setPropertyType(flag: Int) { self.parameterFlag = flag }
    
    // Returns the current flag that this event is using.
    func getPropertyType() -> Int { return self.parameterFlag }
    
    func getPropertyLimit() -> CGFloat { return self.parameterLimit }
    func setPropertyLimit(limit: CGFloat) { self.parameterLimit = limit; }
    
    func setOriginPoint(pt: CGPoint) { self.originPoint = pt }
    
    ////////////////////////////////////////////////////////////
    
    
    private init(isCollision: Bool, isTime: Bool, isParameter: Bool, eo: EventOrganizer) {
        self.isCollision    = isCollision;
        self.isTime         = isTime;
        self.isProperty     = isParameter;
        self.eventorganizer = eo;
    }
    
    static func createCollision(eo:EventOrganizer, sprite1: PWObject, sprite2: PWObject) -> Event? {
        if (!PWObject.isPWObject(sprite1) && !PWObject.isPWObject(sprite2)) { return nil; }
        let event = Event.init(isCollision: true, isTime: false, isParameter: false, eo: eo)
        
        event.sprite1 = sprite1;
        event.sprite2 = sprite2;
        
        return event;
    }
    
    static func createTime(eo:EventOrganizer, time: CGFloat) -> Event? {
        let event = Event.init(isCollision: false, isTime: true, isParameter: false, eo: eo)
        
        //        event.sprite1 = sprite;
        event.initTimer(time);
        event.gameTimePassed = 0;
        
        return event;
    }
    
    // Make sure to specify parameter flag from the struct!
    static func createParameter(eo: EventOrganizer, sprite: PWObject, parameterFlag: Int, limitValue: CGFloat) -> Event? {
        if (!PWObject.isPWObject(sprite)) { return nil; }
        let event = Event.init(isCollision: false, isTime: false, isParameter: true, eo: eo)
        
        event.sprite1 = sprite;
        event.setPropertyType(parameterFlag);
        event.setPropertyLimit(limitValue);
        event.initialPropertyValue = event.getCurrentPropertyValue()
        return event;
    }
}