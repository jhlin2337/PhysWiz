//
//  Stopwatch.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 5/2/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
// Stopwatch class that will allow the use of pausing and playing.

import Foundation

class Stopwatch: NSTimer {
    
    required override init(fireDate date: NSDate, interval ti: NSTimeInterval, target t: AnyObject, selector s: Selector, userInfo ui: AnyObject?, repeats rep: Bool) {
        super.init(ti, target: t, selector: s, userInfo: ui, repeats: rep)
    }
}