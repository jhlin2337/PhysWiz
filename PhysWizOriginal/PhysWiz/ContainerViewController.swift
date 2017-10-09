//
//  ContainerViewController.swift
//  PhysWiz
//
//  Created by Yosvani Lopez on 4/16/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation
import UIKit

class ContainerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    let staticObjects = ["Ramp", "Platform", "Wall", "Round", "Pulley"]
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var physicsLog: UIView!
    @IBOutlet weak var objectMenu: UIBarButtonItem!
    @IBOutlet weak var gadgetMenu: UIBarButtonItem!
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var physicsLogButton: UIBarButtonItem!
    var GameVC: GameViewController!
    var PhysicsLogVC: PhysicsLogViewController!
    var TableVC: TableViewController!
    var objectflag = 0
    var gadgetflag = 0
    let nullflag = 9
    override func viewDidLoad() {
        super.viewDidLoad()
        // handles animation of object and gadget menus
        if self.revealViewController() != nil {
            gadgetMenu.target = revealViewController()
            gadgetMenu.action = "revealToggle:"
            objectMenu.target = revealViewController()
            objectMenu.action = "rightRevealToggle:"
            // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This Builds and animates the input box this is  called when the physics log button is pressed it also maintains a global on off switch logpresented in order to correctly resize the screen
    let duration = 0.5
    var Logpresented = false
    @IBAction func showPhysicsLog(sender: AnyObject) {
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            
            if !self.Logpresented {
                var t = CGAffineTransformIdentity
                t = CGAffineTransformScale(t, 1.0 , 0.75)
                t = CGAffineTransformTranslate(t, 0.0, -110.0)
                self.gameView.transform = t
                self.physicsLog.transform = CGAffineTransformMakeTranslation(0, -110)
                self.Logpresented = true
                
                
            } else {
                self.physicsLog.transform = CGAffineTransformMakeTranslation(0, self.view.frame.height - self.gameView.frame.height)
                self.gameView.transform = CGAffineTransformIdentity
                self.Logpresented = false
            }
            
            }, completion: { finished in
        })
        
    }
    
    @IBAction func savePopover(sender: AnyObject) {
        self.performSegueWithIdentifier("popoverSaveView", sender: self)
    }
    
    @IBAction func loadPopover(sender: AnyObject) {
        self.performSegueWithIdentifier("popoverLoadView", sender: self)
    }
    
    // give access from childviewcontrollers to the parentview controller(self)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "toGameView") {
            GameVC = segue.destinationViewController as! GameViewController
            GameVC.parentVC = self
        }
        
        if (segue.identifier == "toPhysicsLog") {
            PhysicsLogVC = segue.destinationViewController as! PhysicsLogViewController
            PhysicsLogVC.parentVC = self
        }
        
        if (segue.identifier == "popoverSaveView") {
            let saveVC = segue.destinationViewController as! SavingViewController
            let saveController = saveVC.popoverPresentationController
            saveVC.parentVC = self
            
            if saveController != nil {
                saveController?.delegate = self
            }
            
            saveVC.preferredContentSize = CGSizeMake(300, 300)
        }
        
        if (segue.identifier == "popoverLoadView") {
            let loadVC = segue.destinationViewController as! LoadingViewController
            let loadController = loadVC.popoverPresentationController
            loadVC.parentVC = self
            
            if loadController != nil {
                loadController?.delegate = self
            }
            
            loadVC.preferredContentSize = CGSizeMake(300, 300)
        }
      
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // return from selecting table object
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
    }
    // tells whether the tables are open or not
    func tableAreOpen() -> Bool {
        if TableVC != nil {
            if (TableVC.isViewLoaded() && (TableVC.view.window != nil)) {
                    return true
                }
        }
        return false
    }


    // Finds the index on the table that the user selected
    func setObjectFlag(index: Int) {
        //set other flag to null
        if index != 9 {
            gadgetflag = nullflag
        }
        changeToObjectInputBox()
        objectflag = index
    }
    
    func setGadgetFlag(index: Int) {
        // set other flag to null
        if index != 0 {
            objectflag = nullflag
        }
        if index > 2 && index < 8  {
            changeToGadgetInputBox(staticObjects[index - 3]) // four is array offset
        }
        gadgetflag = index
    }
    func getObjectFlag()->Int{
        if tableAreOpen() {
        return objectflag
        }
        else {
            objectflag = nullflag
            return nullflag
        }
    }
    func getGadgetFlag()->Int{
        if tableAreOpen() {
        return gadgetflag
        }
        else {
            gadgetflag = nullflag
            return nullflag
        }
    }
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        return PhysicsLogVC.getInput()
    }
    // Resets the input fields in the input box
    func setsInputBox(input: [Float], state: String) {
        PhysicsLogVC.setsInputBox(input, state: state)
    }
    // sets input box with values
    func setsGadgetInputBox(gadgetType: String, input: [Float], state: String){
        return PhysicsLogVC.setsGadgetInputBox(gadgetType, input: input, state: state)
    }
    // adds object to selection list 
    func addObjectToList(ID: Int) {
        PhysicsLogVC.addObjectToList(ID)
    }
    func removeObjectFromList(ID: Int) {
        PhysicsLogVC.removeObjectFromList(ID)
    }
    func removeAllFromList() {
        PhysicsLogVC.removeAllFromList()
    }
    func changeSelectedObject(ID: Int) {
       GameVC.changeSelectedObject(ID)
    }
    func setsElapsedTime(Time: Float) {
        return GameVC.setsElapsedTime(Time)
        }
    func changeToEndSetter() {
        PhysicsLogVC.changeToEndSetter()
    }
    func changeToMainView(){
        PhysicsLogVC.changeToMainView()
    }
    func changeToGadgetInputBox(gadgetType: String) {
        PhysicsLogVC.changeToGadgetInputBox(gadgetType)
    }
    // changes input back to have object properties 
    func changeToObjectInputBox() {
        PhysicsLogVC.changeToObjectInputBox()
    }
    // retrieves gadget inpute from physics log
    func getGadgetInput(gadgetType: String) -> [String] {
     return PhysicsLogVC.getGadgetInput(gadgetType)
    }
    // returns array of parameters with end setter data
    //if Time ["Time", "value"]
    //if End Parameter ["End-Parameter", "parameter", "value", "object"]
    //if Event ["Event", "event type", "value", "object1", "object2"]
    func getEndSetter()->[String] {
    return PhysicsLogVC.getEndSetter()
    }
    func deselectTextBox() {
        PhysicsLogVC.deselectTextBox()
    }
    func setsSelectedType(type: String) {
        PhysicsLogVC.setsSelectedType(type)
    }
}
