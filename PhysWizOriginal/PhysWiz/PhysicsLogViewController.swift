 //
//  PhysicsLogViewController.swift
//  PhysWiz
//
//  Created by Yosvani Lopez on 4/16/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation
import UIKit
import Darwin
 class PhysicsLogViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate  {
    var activeLogView: UIView?
    var currentTextField: UITextField?
    var objects = ["none", "test"]
    var parameterNames = ["Mass", "Px", "Py","Vx", "Vy", "Av", "Ax", "Ay", "Fx", "Fy"]
    let endSetterParameterNames = ["Distance", "Height","Velocity x", "Velocity y", "Angular Velocity", "Acceleration x", "Acceleration y" ]
    let endSetterEventNames = ["Collision" ]
    var objectIDMap = [String: Int](); // Each object name will have an ID associated with it
    var parentVC = ContainerViewController()
    var selectedType = ""
    @IBOutlet var physicsLog: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register the UITableViewCell class with the tableView
        self.objectSelector?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        // make input box text fields delegates of physicslog view controller so that we could find which is currently being edited (all the text boxes to be edited by num pad must be added here)
        Mass.delegate = self;
        Px.delegate = self;
        Py.delegate = self;
        Vx.delegate = self;
        Vy.delegate = self;
        Ax.delegate = self;
        Ay.delegate = self;
        Fx.delegate = self;
        Fy.delegate = self;
        Av.delegate = self;
    EndParameterInputBox.delegate = self;
        // Move all the option boxes to the same spot in so that toggling is simply done with hide and unhide 
        self.activeLogView = self.mainLogView
        self.EndSetter.transform = CGAffineTransformMakeTranslation(0, -200)
        self.SettingsBox.transform = CGAffineTransformMakeTranslation(0, -400)
        self.ChosenEndView.transform = CGAffineTransformMakeTranslation(0, -600)
        self.WorldSettingBox.transform = CGAffineTransformMakeTranslation(500, -200)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

    }
    
    // save the text field that is being edited
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField?.backgroundColor = UIColor.whiteColor()
        currentTextField = textField
        currentTextField?.inputView = nil
        textField.resignFirstResponder()
        textField.backgroundColor = UIColor.init(red: 0.8314, green: 0.8667, blue: 0.9882, alpha: 1.0) //light yellow
            }
    func deselectTextBox() {
    currentTextField?.backgroundColor = UIColor.whiteColor()
     currentTextField = nil
    }
    
    // The input box contains all the text fields for the user to input information.
    // The type of information being passed is declared below the inputbox declaration.
    // This includes mass, px, py, vx, vy, ax, ay, etc...
    // Gets the input from all the TextFields inside the inputBox.
    @IBOutlet weak var InputBox: UIView!
    @IBOutlet weak var Mass: UITextField!
    @IBOutlet weak var Px: UITextField!
    @IBOutlet weak var Py: UITextField!
    @IBOutlet weak var Vx: UITextField!
    @IBOutlet weak var Vy: UITextField!
    @IBOutlet weak var Ax: UITextField!
    @IBOutlet weak var Ay: UITextField!
    @IBOutlet weak var Fx: UITextField!
    @IBOutlet weak var Fy: UITextField!
    @IBOutlet weak var Av: UITextField!
    
    // Textbox used to output values 
    @IBOutlet weak var OutputValues: UILabel!
    
    
    // ##############################################################
    //  World Settings View
    // ##############################################################
    @IBOutlet weak var SettingsBox: UIView!
    @IBOutlet weak var WorldSettingBox: UIView!
    @IBOutlet weak var gravitySwitcher: UISwitch!
    
    @IBAction func gravitySwitch(sender: AnyObject) {
        if gravitySwitcher.on == false {
        parentVC.GameVC.currentGame.setGravity(false)
        }
        else {
        parentVC.GameVC.currentGame.setGravity(true)
        }
    }

    // ##############################################################
    //  Settings View
    // ##############################################################
    
    @IBAction func SettingsButton(sender: AnyObject) {
        if selectedType == "object" {
        activeLogView?.hidden = true
        SettingsBox.hidden = false
        activeLogView = SettingsBox
        }
        else {
        activeLogView?.hidden = true
        WorldSettingBox.hidden = false
        activeLogView = WorldSettingBox
        }
        
    }
    // changes velocities types tells whether velocity input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var velocityType: UISwitch!
    @IBAction func changeVelocityType(sender: AnyObject) {
        if velocityType.on {
            let vx = Vx.text
            let vy = Vy.text
            ThirdLabel.text = "V"
            FourthLabel.text = "θ"
            Vx.text = truncateString(String(toMagnitude(vx!, y: vy!)), decLen: 2)
            Vy.text = truncateString(String(toTheta(vx!, y: vy!)), decLen: 2)
            }
        if !velocityType.on {
            let v = Vx.text
            let theta = Vy.text
            ThirdLabel.text = "Vx"
            FourthLabel.text = "Vy"
            Vx.text = truncateString(String(toX(v!, theta: theta!)), decLen: 2)
            Vy.text = truncateString(String(toY(v!, theta: theta!)), decLen: 2)
        }
    }
    // changes acceleration types tells whether acceleration input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var accelerationType: UISwitch!
    @IBAction func changeAccelerationType(sender: AnyObject) {
        if accelerationType.on {
            let ax = Ax.text
            let ay = Ay.text
            FifthLabel.text = "A"
            SixthLabel.text = "θ"
            Ax.text = truncateString(String(toMagnitude(ax!, y: ay!)), decLen: 2)
            Ay.text = truncateString(String(toTheta(ax!, y: ay!)), decLen: 2)
        }
        if !accelerationType.on {
            let a = Ax.text
            let theta = Ay.text
            FifthLabel.text = "Ax"
            SixthLabel.text = "Ay"
            Ax.text = truncateString(String(toX(a!, theta: theta!)), decLen: 2)
            Ay.text = truncateString(String(toY(a!, theta: theta!)), decLen: 2)
        }
    }
    // changes force types tells whether force input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var forceType: UISwitch!
    @IBAction func changeForceType(sender: AnyObject) {
        if forceType.on {
            let fx = Fx.text
            let fy = Fy.text
            SeventhLabel.text = "F"
            EighthLabel.text = "θ"
            Fx.text = truncateString(String(toMagnitude(fx!, y: fy!)), decLen: 2)
            Fy.text = truncateString(String(toTheta(fx!, y: fy!)), decLen: 2)
        }
        if !forceType.on {
            let f = Fx.text
            let theta = Fy.text
            SeventhLabel.text = "Fx"
            EighthLabel.text = "Fy"
            Fx.text = truncateString(String(toX(f!, theta: theta!)), decLen: 2)
            Fy.text = truncateString(String(toY(f!, theta: theta!)), decLen: 2)
        }
    }
    // ##############################################################
    //  InputBox
    // ##############################################################
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var FirstLabel: UILabel! //Px
    @IBOutlet weak var SecondLabel: UILabel! //Py
    @IBOutlet weak var ThirdLabel: UILabel! //Vx
    @IBOutlet weak var FourthLabel: UILabel! //Vy
    @IBOutlet weak var FifthLabel: UILabel! //Ax
    @IBOutlet weak var SixthLabel: UILabel! //Ay
    @IBOutlet weak var SeventhLabel: UILabel! //Fx
    @IBOutlet weak var EighthLabel: UILabel! //Fy
    @IBOutlet weak var NinthLabel: UILabel! //Av
    
    
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        var values = [String]()
        values.append(self.Mass.text!)
        values.append(self.Px.text!)
        values.append(self.Py.text!)
        // check velocity type
        if !velocityType.on {
        values.append(self.Vx.text!)
        values.append(self.Vy.text!)
        }
        else {
        values.append(toX(self.Vx.text!, theta: self.Vy.text!))
        values.append(toY(self.Vx.text!, theta: self.Vy.text!))
        }
        values.append(self.Av.text!)
        // check acceleration type
        if !accelerationType.on {
            values.append(self.Ax.text!)
            values.append(self.Ay.text!)
        }
        else {
            values.append(toX(self.Ax.text!, theta: self.Ay.text!))
            values.append(toY(self.Ax.text!, theta: self.Ay.text!))
        }
        // check force type
        if !accelerationType.on {
            values.append(self.Fx.text!)
            values.append(self.Fy.text!)
        }
        else {
            values.append(toX(self.Fx.text!, theta: self.Fy.text!))
            values.append(toY(self.Fx.text!, theta: self.Fy.text!))
        }
        
        return values
    }
    func getGadgetInput(gadgetType: String)-> [String] {
        var values = [String]()
        //properties [ scale, posx, posy, height, base, angle, friction]
        if gadgetType == "Ramp" {
             values.append(Mass.text!) //scale
             values.append(Px.text!) // position x
             values.append(Py.text!) // position y
             values.append(Vx.text!) // height
             values.append(Vy.text!) // base
             values.append(Ax.text!) // angle
             values.append(Ay.text!) // friction
            
        }
        else if gadgetType == "Platform" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // length
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
        }
        else if gadgetType == "Wall" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // height
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
        }
        else if gadgetType == "Round" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // radius
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
     
        }
        else if gadgetType == "Pulley" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // radius
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
        }
       return values
 
    }
    // Resets the input fields in the input box state variable is either static or editable
    func setsInputBox(input: [Float], state: String ) {
        if state == "static" {
        makeInputBoxStatic()
        }
        else if state == "editable" {
        makeInputBoxEditable()
        }
        Mass.text = truncateString(String(input[0]), decLen: 2)
        Px.text = truncateString(String(input[1]), decLen: 2)
        Py.text = truncateString(String(input[2]), decLen: 2)
        Vx.text = truncateString(String(input[3]), decLen: 2)
        Vy.text = truncateString(String(input[4]), decLen: 2)
        Av.text = truncateString(String(input[5]), decLen: 2)
        Ax.text = truncateString(String(input[6]), decLen: 2)
        Ay.text = truncateString(String(input[7]), decLen: 2)
        Fx.text = truncateString(String(input[8]), decLen: 2)
        Fy.text = truncateString(String(input[9]), decLen: 2)
    }
    
    // changes inputbox to static state
    func makeInputBoxStatic() {
        Mass.userInteractionEnabled = false
        Mass.backgroundColor = UIColor.clearColor()
        Px.userInteractionEnabled = false
        Px.backgroundColor = UIColor.clearColor()
        Py.userInteractionEnabled = false
        Py.backgroundColor = UIColor.clearColor()
        Vx.userInteractionEnabled = false
        Vx.backgroundColor = UIColor.clearColor()
        Vy.userInteractionEnabled = false
        Vy.backgroundColor = UIColor.clearColor()
        Av.userInteractionEnabled = false
        Av.backgroundColor = UIColor.clearColor()
        Ax.userInteractionEnabled = false
        Ax.backgroundColor = UIColor.clearColor()
        Ay.userInteractionEnabled = false
        Ay.backgroundColor = UIColor.clearColor()
        Fx.userInteractionEnabled = false
        Fx.backgroundColor = UIColor.clearColor()
        Fy.userInteractionEnabled = false
        Fy.backgroundColor = UIColor.clearColor()
        
    }
    // changes input box to editable state
    func makeInputBoxEditable() {
        Mass.userInteractionEnabled = true
        Mass.backgroundColor = UIColor.whiteColor()
        Px.userInteractionEnabled = true
        Px.backgroundColor = UIColor.whiteColor()
        Py.userInteractionEnabled = true
        Py.backgroundColor = UIColor.whiteColor()
        Vx.userInteractionEnabled = true
        Vx.backgroundColor = UIColor.whiteColor()
        Vy.userInteractionEnabled = true
        Vy.backgroundColor = UIColor.whiteColor()
        Av.userInteractionEnabled = true
        Av.backgroundColor = UIColor.whiteColor()
        Ax.userInteractionEnabled = true
        Ax.backgroundColor = UIColor.whiteColor()
        Ay.userInteractionEnabled = true
        Ay.backgroundColor = UIColor.whiteColor()
        Fx.userInteractionEnabled = true
        Fx.backgroundColor = UIColor.whiteColor()
        Fy.userInteractionEnabled = true
        Fy.backgroundColor = UIColor.whiteColor()
        
    }
    func changeToGadgetInputBox(gadgetType: String) {
        if gadgetType == "Ramp" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Angle"
            FourthLabel.text = "Base"
            FifthLabel.text = "Rotation"
            SixthLabel.text = "Friction"
            FifthLabel.hidden = false
            Ax.hidden = false
            SixthLabel.hidden = false
            Ay.hidden = false
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Platform" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Length"
            FourthLabel.text = "Width"
            FifthLabel.text = "Rotate"
            SixthLabel.text = "Friction"
            FifthLabel.hidden = false
            Ax.hidden = false
            SixthLabel.hidden = false
            Ay.hidden = false
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Wall" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Height"
            FourthLabel.text = "Width"
            FifthLabel.text = "Rotate"
            SixthLabel.text = "Friction"
            FifthLabel.hidden = false
            Ax.hidden = false
            SixthLabel.hidden = false
            Ay.hidden = false
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Round" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Radius"
            FourthLabel.text = "W/H Ratio"
            FifthLabel.text = "Rotate"
            SixthLabel.text = "Friction"
            FifthLabel.hidden = false
            Ax.hidden = false
            SixthLabel.hidden = false
            Ay.hidden = false
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Pulley" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Radius"
            FourthLabel.text = "Friction"
            FifthLabel.hidden = true
            Ax.hidden = true
            SixthLabel.hidden = true
            Ay.hidden = true
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
    }
    // sets up log box for appropriate selection
    func setsSelectedType(type: String) {
     selectedType = type
     if (activeLogView == WorldSettingBox || activeLogView == SettingsBox) {
        SettingsButton(true)
        }
    }
    // Resets the input fields in the input box state variable is either static or editable
    func setsGadgetInputBox(gadgetType: String, input: [Float], state: String ) {
        if state == "static" {
            makeInputBoxStatic()
        }
        else if state == "editable" {
            makeInputBoxEditable()
        }
        Mass.text = truncateString(String(input[0]), decLen: 2)
        Px.text = truncateString(String(input[1]), decLen: 2)
        Py.text = truncateString(String(input[2]), decLen: 2)
        Vx.text = truncateString(String(input[3]), decLen: 2)
        Vy.text = truncateString(String(input[4]), decLen: 2)
        Ax.text = truncateString(String(input[5]), decLen: 2)
        Ay.text = truncateString(String(input[6]), decLen: 2)
    }
    func changeToObjectInputBox() {
        TopLabel.text = "Mass"
        ThirdLabel.text = "Vx"
        FourthLabel.text = "Vy"
        FifthLabel.text = "Ax"
        SixthLabel.text = "Ay"
        FifthLabel.hidden = false
        Ax.hidden = false
        SixthLabel.hidden = false
        Ay.hidden = false
        SeventhLabel.hidden = false
        Fx.hidden = false
        EighthLabel.hidden = false
        Fy.hidden = false
        NinthLabel.hidden = false
        Av.hidden = false
    }
    
    // ##############################################################
    //  Number Pad
    // ##############################################################
    @IBOutlet weak var KeyPad: UIView!
    @IBAction func one(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "1"
        }
    }
    @IBAction func two(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "2"
        }
    }
    @IBAction func three(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "3"
        }
    }
    @IBAction func four(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "4"
        }
    }
    @IBAction func five(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "5"
        }
    }
    @IBAction func six(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "6"
        }
    }
    @IBAction func seven(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "7"
        }
    }
    @IBAction func eight(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "8"
        }
    }
    @IBAction func nine(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "9"
        }
    }
    @IBAction func zero(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "0"
        }
    }
    @IBAction func decimal(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "."
        }
    }
    @IBAction func negative(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "-"
        }
    }
    @IBAction func clear(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = ""
        }
    }
    // ##############################################################
    //  MainView
    // ##############################################################
    func changeToMainView() {
        activeLogView!.hidden = true
        mainLogView.hidden = false
        activeLogView = mainLogView
    }
    
    // ##############################################################
    //  Table Settings for mainView and for Endsetter
    // ##############################################################
    @IBOutlet weak var mainLogView: UIView!
    @IBOutlet weak var objectSelector: UITableView!
    let cellIdentifier = "cellIdentifier"
    var selectionTableData = [String]()
    func addObjectToList(ID: Int) {
       let objectName = "object " + String(ID)
       selectionTableData.append(objectName)
       objectIDMap[objectName] = ID
       objectSelector.reloadData()
       EndObjectList.reloadData()
    }
    func removeObjectFromList(ID: Int) {
        for i in Range(0 ..< selectionTableData.count) {
            if (objectIDMap[selectionTableData[i]] == ID) {
                objectIDMap[selectionTableData[i]] = nil;
                selectionTableData.removeAtIndex(i)
                objectSelector.reloadData()
                EndObjectList.reloadData()
                break
            }
        }
    }
    func removeAllFromList() {
        selectionTableData = [String]()
        objectIDMap.removeAll()
        objectSelector.reloadData()
        EndObjectList.reloadData()
    }
    // UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return count of parameter names list
        if (tableView == EndParameterList && EndType == "End-Parameter") {
          return endSetterParameterNames.count
        }
        // return count of Event names list
        else if (tableView == EndParameterList && EndType == "Event") {
            return endSetterEventNames.count
        }
        // return count list of objects in the scene
        return selectionTableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        // populate parameter names table
        if (tableView == EndParameterList && EndType == "End-Parameter") {
              cell.textLabel?.text = endSetterParameterNames[indexPath.row] as String
            
        }
        // populate Event names table
        else if (tableView == EndParameterList && EndType == "Event") {
            cell.textLabel?.text = endSetterEventNames[indexPath.row] as String
        }
        // populate tables with
        else {
        cell.textLabel?.text = selectionTableData[indexPath.row] as String
        }
        
        return cell
    }
    
    // UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == objectSelector {
            for object in objectIDMap.keys {
                if object == selectionTableData[indexPath.row] {
                    changeToObjectInputBox()
                    parentVC.changeSelectedObject(objectIDMap[object]!)
                }
     
            }
        }
        
        // deals with object table selection for end-parameter
        if tableView == EndObjectList {
            if EndType == "End-Parameter" {
            EndObject = selectionTableData[indexPath.row]
            ObjectIndexQueue[0] = indexPath
            ForObjectLabel.text = "For " + getEndobject()
            }
            // deals with object selection for event
            else if EndType == "Event" {
                if EndObject == "" {
                EndObject = selectionTableData[indexPath.row]
                ObjectIndexQueue[0] = indexPath
                }
                else if EndObject2 == "" {
                EndObject2 = selectionTableData[indexPath.row]
                ObjectIndexQueue[1] = indexPath
                }
                else {
                 EndObjectList.deselectRowAtIndexPath(ObjectIndexQueue[0], animated: false)
                 ObjectIndexQueue[0] = ObjectIndexQueue[1]
                 ObjectIndexQueue[1] = indexPath
                 EndObject = EndObject2
                 EndObject2 = selectionTableData[indexPath.row]
                }
                if EndObject2 != "" {
                let secondID = objectIDMap[EndObject2]
                ForObjectLabel.text = "For " + getEndobject() + " & " + String(secondID!)
                }
                else {
                    ForObjectLabel.text = "For " + getEndobject() + " & "
                }
            }
        }
        // deals with parameter table selection for endsetter
        if tableView == EndParameterList {
            EndParameter = indexPath.row
            if EndType == "End-Parameter" {
             ParameterEqualsTo.text = endSetterParameterNames[EndParameter] + " ="
            }
            else if EndType == "Event" {
                ParameterEqualsTo.text = endSetterEventNames[EndParameter]
            }
        }

    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == EndObjectList {
            if indexPath == ObjectIndexQueue[0] {
                if EndObject2 != "" {
                EndObject = selectionTableData[ObjectIndexQueue[1].row]
                    EndObject2 = ""
                }
                else {
                    EndObject = "" 
                }
                ForObjectLabel.text = "For " + getEndobject() + " & "
                ObjectIndexQueue[0] = ObjectIndexQueue[1]
            }
            else if indexPath == ObjectIndexQueue[1] {
                EndObject2 = ""
                ObjectIndexQueue[1] = NSIndexPath()
                ForObjectLabel.text = "For " + getEndobject() + " & "
            }
            
        }
    }
    // ##############################################################
    //  Simulation End setter
    // ##############################################################
    @IBOutlet weak var EndSetter: UIView!
    @IBOutlet weak var TimeButton: UIButton!
    @IBOutlet weak var EndParameterButton: UIButton!
    @IBOutlet weak var EventButton: UIButton!
    @IBOutlet weak var ChosenEndView: UIView!
    @IBOutlet weak var EndViewTitle: UILabel!
    @IBOutlet weak var EndViewBackButton: UIButton!
    @IBOutlet weak var EndParameterInputBox: UITextField!
    @IBOutlet weak var StopWhenLabel: UILabel!
    @IBOutlet weak var ForObjectLabel: UILabel!
    @IBOutlet weak var EndObjectListBox: UIScrollView!
    @IBOutlet weak var EndObjectList: UITableView!
    @IBOutlet weak var ParameterEqualsTo: UILabel!
    @IBOutlet weak var EndParameterListBox: UIScrollView!
    @IBOutlet weak var EndParameterList: UITableView!
    var EndType = ""
    var EndParameter = 0
    var EndObject = ""
    var EndObject2 = ""
    var ObjectIndexQueue = [NSIndexPath(), NSIndexPath()]
    func changeToEndSetter() {
        activeLogView!.hidden = true
        EndSetter.hidden = false
        activeLogView = EndSetter
    }
    @IBAction func ReturnToEndSetter(sender: AnyObject) {
        resetEndSetter()
        changeToEndSetter()
    }
    // the parameter we are ending for
    func getEndType() -> String {
        return EndType
    }
    // the inputed value to end at
    func getEndData() -> String {
        return EndParameterInputBox.text!
    }
    // the object that the end value is associated with
    func getEndobject() -> String {
        return EndObject
    }
    // the object that the end value is associated with
    func getEndobject2() -> String {
        return EndObject2
    }
    func resetEndSetter() {
        //reset tables
        if EndObject != ""  {
           EndObjectList.deselectRowAtIndexPath(ObjectIndexQueue[0],animated: false)
            ObjectIndexQueue[0] = NSIndexPath()
            EndObject = ""
        }
        if EndObject2 != "" {
            EndObjectList.deselectRowAtIndexPath(ObjectIndexQueue[1],animated: false)
            ObjectIndexQueue[1] = NSIndexPath()
            EndObject2 = ""
        }
        EndType = ""
        if currentTextField == EndParameterInputBox {
            deselectTextBox()
        }
        EndParameterInputBox.text = ""
        EndParameter = 0
        ForObjectLabel.text = "For"
        ParameterEqualsTo.text = ""
        changeToMainView()
    }
    //returns the end event that is currently set
    func getEndSetter() -> [String] {
        var endSettings: [String] = ["", "", "", "", ""]
        if EndType == "Time" {
            endSettings[0] = EndType
            endSettings[1] = EndParameterInputBox.text!
            endSettings[2] = ""
            endSettings[3] = ""
            endSettings[4] = ""
            
        }
        if EndType == "End-Parameter" {
            if EndObject != "" {
            endSettings[0] = EndType
            endSettings[1] = String(EndParameter)
            endSettings[2] = EndParameterInputBox.text!
            endSettings[3] = String(objectIDMap[EndObject]!)
            endSettings[4] = ""
            }
        }
        if EndType == "Event" {
            if EndObject != "" && EndObject2 != "" {
            endSettings[0] = EndType
            endSettings[1] = String(EndParameter)
            endSettings[2] = EndParameterInputBox.text!
            endSettings[3] = String(objectIDMap[EndObject]!)
            endSettings[4] = String(objectIDMap[EndObject2]!)
            }
        }
        resetEndSetter()
        return endSettings
    }
    // Set up endssetter View for Entering Time
    @IBAction func timeSet(sender: AnyObject) {
       resetEndSetter()
       EndType = "Time"
       EndViewTitle.text = "Time"
       ParameterEqualsTo.text = "End-Time:"
       activeLogView!.hidden = true
       StopWhenLabel.hidden = true
       ForObjectLabel.hidden = true
       EndParameterListBox.hidden = true
       EndParameterInputBox.hidden = false
       EndObjectListBox.hidden = true
       ChosenEndView.hidden = false
       activeLogView = ChosenEndView
    }
    
    @IBAction func EndParameterSet(sender: AnyObject) {
        resetEndSetter()
        EndObjectList.allowsMultipleSelection = false
        EndViewTitle.text = "End-Parameter"
        EndType = "End-Parameter"
        EndParameterList.reloadData()
        ForObjectLabel.hidden = false
        StopWhenLabel.hidden = false
        EndParameterInputBox.hidden = false
        ForObjectLabel.hidden = false
        EndParameterListBox.hidden = false
        EndObjectListBox.hidden = false
        ChosenEndView.hidden = false
        activeLogView!.hidden = true
        activeLogView = ChosenEndView
    }
  
    @IBAction func eventSet(sender: AnyObject) {
        resetEndSetter()
        EndObjectList.allowsMultipleSelection = true
        EndViewTitle.text = "Event"
        EndType = "Event"
        ForObjectLabel.hidden = false
        StopWhenLabel.hidden = false
        EndParameterInputBox.hidden = true
        ForObjectLabel.hidden = false
        EndParameterList.reloadData()
        EndParameterListBox.hidden = false
        EndObjectListBox.hidden = false
        ChosenEndView.hidden = false
        activeLogView!.hidden = true
        activeLogView = ChosenEndView
    }

    // ##############################################################
    //  Helper Functions
    // ##############################################################

    // Truncates the string so that it shows only the given
    // amount of numbers after the first decimal.
    // For example:
    // decLen = 3; 3.1023915 would return 3.102
    //
    // If there are no decimals, then it just returns the string.
    func truncateString(inputString: String, decLen: Int) -> String
    {
        return String(format: "%.\(decLen)f", (inputString as NSString).floatValue)
    }
    
    // converts degrees to radians (for use in darwin math)
    func degToRad(degrees: Float) -> Float {
        // M_PI is defined in Darwin.C.math
        return Float(M_PI) * degrees/180.0
    }
    // converts degrees to radians (for use in darwin math)
    func radToDeg(radians: Float) -> Float {
        // M_PI is defined in Darwin.C.math
        return radians/(Float(M_PI)) * 180.0
    }
    // converts to X given magnitude and angle returns 0 if either value is nil (Note: this may need to change to keep current val)
    func toX(velocity: String, theta: String)->String{
        if (Float(velocity) != nil  && Float(theta) != nil) {
            return String(Float(velocity)!*Darwin.cos(degToRad(Float(theta)!)))
        }
        return "0"
    }
    // converts to Y given magnitude and angle returns 0 if either value is nil (Note: this may need to change to keep current val)
    func toY(velocity: String, theta: String)->String{
        if (Float(velocity) != nil  && Float(theta) != nil) {
            return String(Float(velocity)!*Darwin.sin(degToRad(Float(theta)!)))
        }
        return "0"
    }
    func toTheta(x:String, y: String) -> String{
        while (Float(x) != nil  && Float(y) != nil) {
            return  String(radToDeg(Darwin.atan(Float(y)!/Float(x)!)))
        }
        return "0"
    }
    func toMagnitude (x:String, y: String) -> String {
        while (Float(x) != nil  && Float(y) != nil) {
            return String(Darwin.sqrt(Darwin.powf(Float(x)!, 2) + Darwin.powf(Float(y)!, 2)))
        }
        return "0"
        
    }
    
}
