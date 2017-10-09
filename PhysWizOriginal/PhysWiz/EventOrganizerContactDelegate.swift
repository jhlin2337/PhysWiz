//
//  EventOrganizerContactDelegate.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/26/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
//  The contact delegate that will handle when two objects
//  collide. It will communicate with the EventOrganizer
//  to check if the objects collided is a highlighted event.

import Foundation
import UIKit
import SpriteKit

class EventOrganizerContactDelegate: NSObject, SKPhysicsContactDelegate {
    //    var timeEvents      = [Event](); // Anything that handles time
    //    var posEvents       = [Event](); // Anything that handles position, acceleration, velocity
    //    var collisionEvents = [Event](); // Handles Collision Events;
    var eventOrganizer: EventOrganizer! = nil;
    var event: Event! = nil;
    
    // This part needs to be set so that the contact delegate part of
    // this class will call the appropriate function.
    func setCollisionEvent(event: Event) {
        if (!event.isCollisionEvent()) { return }
        self.event = event;
    }
    
    // This function is called by PhysicsWorld of gamescene everytime
    // objects collide.
    func didBeginContact(contact: SKPhysicsContact) {
        if (event == nil) { return; }
        let node1 = contact.bodyA.node!;
        let node2 = contact.bodyB.node!;
        
        // For now, only sprites can collide with each other.
        if (!PWObject.isPWObject(node1) || !PWObject.isPWObject(node2)) { return; }
        let sprite1 = node1 as! PWObject
        let sprite2 = node2 as! PWObject
        
        // Check to see if the collision occured between correct objects.
        event.checkAndTriggerCollision(sprite1, sprite2: sprite2);
    }
    
    
    required init(eo: EventOrganizer) {
        eventOrganizer = eo;
    }
    
}