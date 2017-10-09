//
//  GameScene.swift
//  PhysWiz
//
//  Created by James Lin on 3/21/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import SpriteKit
import Foundation

// Contact bitmasks.
struct PhysicsCategory {
    static let None              : UInt32 = 0
    static let All               : UInt32 = UInt32.max
    static let Sprites           : UInt32 = 0b1       // 1
    static let StaticObjects     : UInt32 = 0b10      // 2
}

class GameScene: SKScene , SKPhysicsContactDelegate{
    var gadgetNode1: SKNode! = nil;
    var gadgetNode2: SKNode! = nil;
    
    var springglobal = [SKSpriteNode: [SKNode]]() // Spring that maps to two other nodes. PWOBJECT
    var initialHeight = [SKSpriteNode: CGFloat](); // PWOBJECT
    var labelMap = [PWObject: SKLabelNode](); // Each sk spritenode will have a label associated with it. PWOBJECT
   
    // Maps each object's ID to the object itself.
    var objIdToSprite = [Int: PWObject]();
    
    var pwPaused = true // Paused
    var button: SKSpriteNode! = nil
    var stop: SKSpriteNode! = nil
    var trash: SKSpriteNode! = nil
    
    var background: SKSpriteNode! = nil
    let cam = SKCameraNode()
    var camPos = CGPoint()
    var PWObjects = [PWObject]()
    var TimeCounter = 0.0
    var Timer: NSTimer! = nil;
    var PWStaticObjects = [PWStaticObject]()
    var ropeConnections = [SKNode]()
    var springConnections = [SKNode]()
    var rodConnections = [SKNode]()
    
    var toggledSprite = shapeType.CIRCLE;
    var shapeArray = [shapeType]();
    var containerVC: ContainerViewController!
    // The selected object for parameters
    var selectedSprite: PWObject! = nil
    var selectedGadget: PWStaticObject! = nil
    var objectProperties: [PWObject : [Float]]!
    var gadgetProperties: [PWStaticObject : [Float]]!
    var defaultObjectProperties: [Float] = [1, 0 ,0 ,0, 0, 0, 0 ,0 ,0,0]
    var updateFrameCounter = 0
    // used to scale all parameters from pixels to other metric system
    // not applied to mass or values not associated with pixels
    var pixelToMetric = Float(100)
    
    // gives each object an unique number ID
    var ObjectIDCounter = 0

    
    // keeps track of time parameter
    var runtimeCounter = 0
    
    // Event Organizers and contact delegates!
    var eventorganizer: EventOrganizer! = nil;
    
    // This enumeration defines the standard indices for each of the shape properties.
    // To use, you will have to obtain the raw value of the enumeration:
    // shapePropertyIndex(rawValue)
    enum shapePropertyIndex : Int{
        case MASS   = 0
        case PX     = 1
        case PY     = 2
        case VX     = 3
        case VY     = 4
        case ANG_V  = 5
        case AX     = 6
        case AY     = 7
        case FX     = 8
        case FY     = 9
    }
    
    // The game view controller will be the strong owner of the gamescene
    // This reference holds the link of communication between the interface
    // and the game scene itself.
    override func didMoveToView(view: SKView) {
        // make gravity equal to 981 pixels
        self.physicsWorld.gravity = CGVectorMake(0.0, -6.54);
        
        let gestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        self.addChild(self.cam)
        self.camera = cam
        self.camera?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        camPos = self.camera!.position
        
        /* Setup your scene here */
        cam.addChild(self.createPausePlay())
        cam.addChild(self.createStop())
        cam.addChild(self.createTrash())
        self.addChild(self.createBG())
        self.addChild(PWObject.createFloor(CGSize.init(width: background.size.width, height: 0.01))) // Floor
        self.physicsWorld.speed = 0
        objectProperties = [PWObject: [Float]]()
        gadgetProperties = [PWStaticObject : [Float]]()
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: background.size.width, height: background.size.height))
        
        // INIT Shape arrays to call later in flag function
        shapeArray.append(shapeType.CIRCLE)
        shapeArray.append(shapeType.SQUARE)
        shapeArray.append(shapeType.TRIANGLE)
        shapeArray.append(shapeType.CRATE)
        shapeArray.append(shapeType.BASEBALL)
        shapeArray.append(shapeType.BRICKWALL)
        shapeArray.append(shapeType.AIRPLANE)
        shapeArray.append(shapeType.BIKE)
        shapeArray.append(shapeType.CAR)
        
        PWObject.initStaticVariables();
        
        ////////////////////////////////////////////////////////////
        //////////////// Initialize Event Organizers ///////////////
        ////////////////////////////////////////////////////////////
        eventorganizer = EventOrganizer.init(gamescene: self); // Sets contact delegate inside.
    }
    
    // Creates a background for the gamescene
    func createBG() -> SKSpriteNode {
        background = SKSpriteNode(imageNamed: "bg")
        background.anchorPoint = CGPointZero
        background.name = "background"
        background.size.height = self.size.height * 20
        background.size.width = self.size.width * 30
        background.zPosition = -2
        return background
    }

    // Creates a node that will act as a pause play button for the user.
    func createPausePlay() -> SKSpriteNode {
        button = SKSpriteNode(imageNamed: "play.png")
        button.position.x += self.camera!.position.x/1.1
        button.position.y += self.camera!.position.y/1.4
        button.size = CGSize(width: 50, height: 50)
        button.name = "button"
        return button
    }
    // turn gravity on and off
    func setGravity(isOn: Bool) {
        if (isOn) {
        self.physicsWorld.gravity = CGVectorMake(0.0, -6.54);
        }
        else {
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        }
        
    }
    
    // Creates a trash bin on the lower right hand side of the screen
    func createTrash() -> SKSpriteNode {
        trash = SKSpriteNode(imageNamed: "trash.png")
        trash.position.x += self.camera!.position.x/1.1
        trash.position.y -= self.camera!.position.y/1.2
        trash.zPosition = -1
        trash.size = CGSize(width: 60, height: 60)
        trash.name = "trash"
        return trash
    }
    
    // Creates a node that will act as a stop button for the user.
    func createStop() -> SKSpriteNode {
        stop = SKSpriteNode(imageNamed: "stop.png")
        stop.position.x += self.camera!.position.x/1.3
        stop.position.y += self.camera!.position.y/1.4
        stop.size = CGSize(width: 50, height: 50)
        stop.name = "stop"
        return stop
    }
    
    // return parameters of given object from either the object itself or dictionary
   func getParameters(object: PWObject) -> [Float]{
        var parameterOutput = [Float]()
        // handle properties that remain the same when static and when dynamic
        parameterOutput.insert(Float(object.getMass()), atIndex: shapePropertyIndex.MASS.rawValue)
        parameterOutput.insert(Float((object.getPos().x))/pixelToMetric, atIndex: shapePropertyIndex.PX.rawValue)
        parameterOutput.insert(Float((object.getPos().y))/pixelToMetric, atIndex: shapePropertyIndex.PY.rawValue)
        // handle properties that lose values when paused, because velocity goes to zero when paused
        if pwPaused {
            if objectProperties[object] != nil {
                for i in 3 ..< 10 { parameterOutput.insert(Float(objectProperties[object]![i]), atIndex: i) }
            }
            else {
                for i in 3 ..< 10 { parameterOutput.insert(0, atIndex: i) }
            }
        } else {
            parameterOutput.insert(Float((object.getVelocity().dx))/pixelToMetric, atIndex: shapePropertyIndex.VX.rawValue)
            parameterOutput.insert(Float((object.getVelocity().dy))/pixelToMetric, atIndex: shapePropertyIndex.VY.rawValue)
            parameterOutput.insert(Float((object.getAngularVelocity()))/pixelToMetric, atIndex: shapePropertyIndex.ANG_V.rawValue)
            for i in 6 ..< 10 { parameterOutput.insert(Float(objectProperties[object]![i]), atIndex: i) }
        }
        return parameterOutput
    }
     func getGadgetParameters(object: PWStaticObject) -> [Float]{
        var values = object.getProperties(object.name!)
        //ramp
        if object.name! == "Ramp" {
            values[1] =  values[1]/pixelToMetric
            values[2] =  values[2]/pixelToMetric
            values[3] =  values[3]
            values[4] =  values[4]/pixelToMetric
        }
        //platform
        else if object.name! == "Platform" {
            values[1] =  values[1]/pixelToMetric
            values[2] =  values[2]/pixelToMetric
            values[3] =  values[3]/pixelToMetric
            values[4] =  values[4]/pixelToMetric
        }
        //wall 
        else if object.name! == "Wall" {
            values[1] =  values[1]/pixelToMetric
            values[2] =  values[2]/pixelToMetric
            values[3] =  values[3]/pixelToMetric
            values[4] =  values[4]/pixelToMetric
        }
        //round 
        else if object.name! == "Round" {
            values[1] =  values[1]/pixelToMetric
            values[2] =  values[2]/pixelToMetric
            values[3] =  values[3]/pixelToMetric
        
        }
        //pulley
        else if object.name! == "Pulley" {
            values[1] =  values[1]/pixelToMetric
            values[2] =  values[2]/pixelToMetric
            values[3] =  values[3]/pixelToMetric
        }
        return values
    }
    
    // Stores all object properties in the scene (velocity, position, and acceleration) to a data structure.
    // This function will be called when the user presses pause. 
    // Returns a dictionary with keys as each shape in the scene and
    // the values as a float array with the shape properties as defined
    // in the shapePropertyIndex enumeration.
    func saveAllObjectProperties() -> [PWObject: [Float]]
    {
        var propertyDict = [PWObject: [Float]]()
        for object in self.children {
            if (!PWObject.isPWObject(object)) { continue; }
            
            let sprite = object as! PWObject
            if (sprite.isSprite()) {
                propertyDict[sprite] = getParameters(sprite)
            }
        }
        
        return propertyDict
    }
    
    // Restores all the object properties of each shape given an dictionary
    // with keys as each shape in the scene and values as a float array 
    // with the shape properties as defined in the shapePropertyindex enumeration.
    // DEVELOPER'S NOTE: MAKE SURE TO ADD FORCES TO THIS
    // WITH THE CURRENT IMPLMENETATION OF getParameters,
    // WE ARE MISSING FORCES/ACCELERATION
    func restoreAllobjectProperties(inputDictionary: [PWObject: [Float]])
    {
        if (inputDictionary.count == 0) { return } // input contains nothing
        
        for (sprite, properties) in inputDictionary {
            if (sprite.isSprite()) {
                // Note: This format is based on the getObjectProperties function.
                sprite.setMass (CGFloat(properties[0]))
                sprite.setPos(CGFloat(properties[1]*pixelToMetric), y: CGFloat(properties[2]*pixelToMetric))
                sprite.setVelocity(CGFloat(properties[3]*pixelToMetric), y: CGFloat(properties[4]*pixelToMetric))
                sprite.setAngularVelocity(CGFloat(properties[5]*pixelToMetric))

            }
        }
    }
    // restores gadget properties
    func applyAllGadgetProperties(inputDictionary: [PWStaticObject: [Float]], forallobjects: Bool)
    {
        if (inputDictionary.count == 0) { return } // input contains nothing
        
        for (gadget, properties) in inputDictionary {
            let location = CGPoint(x: CGFloat(pixelToMetric*properties[1]), y: CGFloat(pixelToMetric*properties[2]))
            
            if (PWStaticObject.isPWStaticObject(gadget)) {
                if selectedGadget != nil {
                    if forallobjects == false && gadget != selectedGadget {
                        continue
                    }
                }
                if gadget.name == "Ramp" {
                    gadget.editRamp(CGFloat(properties[0]), location: location, angle: CGFloat(properties[3]), base: CGFloat(pixelToMetric*properties[4]), rotation: CGFloat(properties[5]), friction: CGFloat(properties[6]))
                    
                }
                else if gadget.name == "Platform" {
                    gadget.editPlatform(CGFloat(properties[0]), location: location, length: CGFloat(pixelToMetric*properties[3]), width: CGFloat(pixelToMetric*properties[4]), rotation: CGFloat(properties[5]), friction: CGFloat(properties[6]))
                    
                }
                else if gadget.name == "Wall" {
                    gadget.editWall(CGFloat(properties[0]), location: location, height: CGFloat(pixelToMetric*properties[3]), width: CGFloat(pixelToMetric*properties[4]), rotation: CGFloat(properties[5]), friction: CGFloat(properties[6]))
                    
                }
                else if gadget.name == "Round" {
               gadget.editRound(CGFloat(properties[0]), location: location, radius: CGFloat(pixelToMetric*properties[3]), whratio: CGFloat(properties[4]), rotation: CGFloat(properties[5]), friction: CGFloat(properties[6]))
                    
                }
                else if gadget.name == "Pulley" {
                gadget.editPulley(CGFloat(properties[0]), location: location, radius: CGFloat(pixelToMetric*properties[3]), other: CGFloat(properties[4]), other2: CGFloat(properties[5]), friction: CGFloat(properties[6]))
                    
                }
            }
        }
    }
    // Checks to see if the location that is valid (i.e. if it's actually a point on the game scene plane itself)
    // The button is considered a valid point, so long as it is not another PWObject.
    func checkValidPoint(location: CGPoint) -> Bool {
        let nodes = nodesAtPoint(location);
        for node in nodes {
            if(node.name == "button") { return false }
            if(PWObject.isPWObject(node)) { return false }
            if(PWStaticObject.isPWStaticObject(node)) { return false }
        }
        
        return true
    }
    
    // Checks to see if there is a node at the location
    // Returns the sprite if it's true, otherwise return
    // the false.
    func checkLocforNode(location: CGPoint) -> SKNode! {
        if(nodeAtPoint(location) == self) {
            return nil
        }
        return nodeAtPoint(location)
        
    }
    
    func createRopeBetweenNodes(node1: SKNode, node2: SKNode) {
        ropeConnections.append(node1)
        ropeConnections.append(node2)
        
        let node1Mid = node1.position
        let node2Mid = node2.position
        let spring = SKPhysicsJointLimit.jointWithBodyA(node1.physicsBody!, bodyB: node2.physicsBody!, anchorA: node1Mid, anchorB: node2Mid)
        self.physicsWorld.addJoint(spring)
        
        self.addChild(Rope.init(parentScene: self, node: node1, node: node2, texture: "rope.png"))
    }
    
    func createSpringBetweenNodes(node1: SKNode, node2: SKNode) {
        springConnections.append(node1)
        springConnections.append(node2)
        
        let n1 = node1.position
        let n2 = node2.position
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        
        // Create the joint between the two objects
        let spring = SKPhysicsJointSpring.jointWithBodyA(node1.physicsBody!, bodyB: node2.physicsBody!, anchorA: n1, anchorB: n2)
        spring.damping = 0.5
        spring.frequency = 0.5
        self.physicsWorld.addJoint(spring)
        
        // Actually create a spring image with physics properties.
        let springobj = SKSpriteNode(imageNamed: "spring.png")
        let nodes = [node1, node2];
        springglobal[springobj] = nodes;
        
        let angle = CGFloat(atan2f(Float(deltay), Float(deltax)))
        springobj.zRotation = angle + 1.57 // 1.57 because image is naturally vertical
        initialHeight[springobj] = springobj.size.height;
        springobj.yScale = distance/springobj.size.height / 4;
        let xOffset = deltax / 2
        let yOffset = deltay / 2
        springobj.position = CGPoint.init(x: n1.x - xOffset, y: n1.y - yOffset)
        springobj.zPosition = -1
        self.addChild(springobj);
    }
    
    // Scales the springs between objects according to their distances.
    func updateSprings()
    {
        for (spring, nodes) in springglobal {
            let springnode1 = nodes[0];
            let springnode2 = nodes[1];
            
            let deltax = springnode1.position.x - springnode2.position.x
            let deltay = springnode1.position.y - springnode2.position.y
            let distance = sqrt(deltax * deltax + deltay*deltay)
            spring.yScale = distance/initialHeight[spring]!;
            let xOffset = deltax / 2
            let yOffset = deltay / 2
            let angle = CGFloat(atan2f(Float(deltay), Float(deltax)))
            spring.zRotation = CGFloat(angle + 1.57) // 1.57 because image is naturally vertical
            spring.position = CGPoint.init(x: springnode1.position.x - xOffset, y: springnode1.position.y - yOffset)
        }
    }
    
    // Updates relative distance labels when an object is being dragged.
    func updateNodeLabels()
    {
        // I moved the selected sprite check out of the loop as its not necessary to check every time
        if (selectedSprite == nil) { return }
        
        // Otherwise, label is on when simulation is NOT running
        for node in self.children
        {
            if (!PWObject.isPWObject(node)) { continue; }
            let sprite = node as! PWObject
            if (sprite == selectedSprite) { continue }
            
            if (labelMap[sprite] == nil) {
                let newLabel = SKLabelNode.init(text: "name")
                newLabel.fontColor = UIColor.blackColor();
                newLabel.fontSize = 15.0
                newLabel.fontName = "AvenirNext-Bold"
                labelMap[sprite] = newLabel;
                self.addChild(newLabel);
            }
            
            let label = labelMap[sprite];
            label?.hidden = false;
            
            let xPos = sprite.getPos().x - selectedSprite.getPos().x
            let yPos = sprite.getPos().y - selectedSprite.getPos().y
            
            let dist = "(" + truncateString(String(xPos / CGFloat(pixelToMetric)), decLen: 2) + ", " + truncateString(String(yPos / CGFloat(pixelToMetric)), decLen: 2) + ")"
            label?.text = dist
            let pos = sprite.getPos();
            label?.position = CGPoint.init(x: pos.x, y: pos.y + sprite.size.height/2)
        }
    }
    
    // Truncates the string so that it shows only the given
    // amount of numbers after the first decimal.
    // For example:
    // decLen = 3; 3.1023915 would return 3.102
    //
    // If there are no decimals, then it just returns the string.
    func truncateString(inputString: String, decLen: Int) -> String {
        return String(format: "%.\(decLen)f", (inputString as NSString).floatValue)
    }
    
    func hideLabels()
    {
        for node in self.children{
            if (!PWObject.isPWObject(node)) { continue }
            let sprite = node as! PWObject
            let label = labelMap[sprite];
            
            if (label != nil) { label?.hidden = true; }
        }
    }
    
    
    func createRodBetweenNodes(node1: SKNode, node2: SKNode) {
        rodConnections.append(node1)
        rodConnections.append(node2)
        
        if !(node1 is PWObject) { return; }
        if !(node2 is PWObject) { return; }
        
        let node1 = node1 as! PWObject
        let node2 = node2 as! PWObject
        
        let n1 = node1.position
        let n2 = node2.position
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        
        let angle = CGFloat(atan2f(Float(deltay), Float(deltax)))
        
        let dimension = CGSizeMake(distance, 4)
        let rod = SKShapeNode(rectOfSize: dimension)
        rod.physicsBody = SKPhysicsBody.init(rectangleOfSize: dimension)
        
        rod.zRotation = CGFloat(angle)
        let xOffset = deltax / 2
        let yOffset = deltay / 2
        rod.position = CGPoint.init(x: n1.x - xOffset, y: n1.y - yOffset)
        rod.zPosition = -1
        
        rod.fillColor = UIColor.blueColor()
        
        self.addChild(rod);
        
        let rodJoint1 = SKPhysicsJointFixed.jointWithBodyA(node1.physicsBody!, bodyB: rod.physicsBody!, anchor: n1)
        let rodJoint2 = SKPhysicsJointFixed.jointWithBodyA(node2.physicsBody!, bodyB: rod.physicsBody!, anchor: n2)
        self.physicsWorld.addJoint(rodJoint1)
        self.physicsWorld.addJoint(rodJoint2)
    }
    // ##############################################################
    //  Create Static Objects
    // ##############################################################

    // create ramp static gadget
    func createRamp(location:CGPoint){
        let Ramp = PWStaticObject.init(objectStringName: "Ramp", position: location, isMovable: true, isSelectable: true)
        gadgetProperties[Ramp] = getGadgetParameters(Ramp);
        self.addChild(Ramp)
        selectGadget(Ramp)
        PWStaticObjects += [Ramp]
    }
    // creates platform static gadget
    func createPlatform(location:CGPoint){
        let Platform = PWStaticObject.init(objectStringName: "Platform", position: location, isMovable: true, isSelectable: true)
        gadgetProperties[Platform] = getGadgetParameters(Platform)
        self.addChild(Platform)
        selectGadget(Platform)
        PWStaticObjects += [Platform]
    }
    // creates wall static gadget
    func createWall(location:CGPoint){
        let Wall = PWStaticObject.init(objectStringName: "Wall", position: location, isMovable: true, isSelectable: true)
        gadgetProperties[Wall] = getGadgetParameters(Wall)
        self.addChild(Wall)
        selectGadget(Wall)
        PWStaticObjects += [Wall]
    }
    // creates round static gadget
    func createRound(location:CGPoint){
        let Round = PWStaticObject.init(objectStringName: "Round", position: location, isMovable: true, isSelectable: true)
        gadgetProperties[Round] = getGadgetParameters(Round)
        self.addChild(Round)
        selectGadget(Round)
        PWStaticObjects += [Round]
    }
    // creates Pulley static gadget
    func createPulley(location:CGPoint){
        let Pulley = PWStaticObject.init(objectStringName: "Pulley", position: location, isMovable: true, isSelectable: true)
        gadgetProperties[Pulley] = getGadgetParameters(Pulley)
        self.addChild(Pulley)
        selectGadget(Pulley)
        PWStaticObjects += [Pulley]
    }
    // ##############################################################
    // Selects a sprite in the game scene.
    // ##############################################################
    func selectSprite(sprite: PWObject?) {
        let prevSprite = selectedSprite;
        if (prevSprite != nil) { prevSprite.setUnselected() }
        // Passed in sprite is nil so nothing is selected now.
        if (sprite == nil) {
            selectedSprite = nil
            return
        }
        deselectGadget()
        selectedSprite = sprite
        containerVC.setsInputBox(objectProperties[selectedSprite]!, state: "editable")
        selectedSprite.setSelected();
        containerVC.setsSelectedType("object")
        
    }
    func selectGadget(sprite: PWStaticObject?) {
        let prevGadget = selectedGadget
        if (prevGadget != nil) { prevGadget!.setUnselected() }
        // Passed in sprite is nil so nothing is selected now.
        if (sprite == nil) {
            selectedSprite.setUnselected()
            selectedGadget = nil
            return
        }
        selectSprite(nil)
        selectedGadget = sprite;
        let values = getGadgetParameters(selectedGadget)
    containerVC.setsGadgetInputBox(selectedGadget.name!, input: values, state: "editable")
        selectedGadget.setSelected();
        containerVC.setsSelectedType("gadget")
        
    }
    
    func deselectGadget() {
        if selectedGadget != nil {
        selectedGadget.setUnselected()
        selectedGadget = nil
        }
    }
    // ##############################################################
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            containerVC.deselectTextBox()
            let location:CGPoint = touch.locationInNode(background)
            let touchedNode = self.nodeAtPoint(location)
            
            //////////////////////////////////
            //////// CREATE OBJECT ///////////
            //////////////////////////////////
            // Make sure the point that is being touched is part of the game scene plane is part of the game
            if((checkValidPoint(location) || touchedNode.name == "Round") && pwPaused ) {
                // When clicking outside a In the scene return to main scene
                containerVC.changeToMainView()
                if (touchedNode.name == "Round") {
                    selectGadget(touchedNode as? PWStaticObject)
                    containerVC.changeToGadgetInputBox(selectedGadget.name!)
                }
                else if (containerVC.getGadgetFlag() == 9) {
                    deselectGadget()
                }
                else if (containerVC.getGadgetFlag() == 3) {
                    createRamp(location)
                }
                else if (containerVC.getGadgetFlag() == 4) {
                    createPlatform(location)
                }
                else if (containerVC.getGadgetFlag() == 5) {
                    createWall(location)
                }
                else if (containerVC.getGadgetFlag() == 6) {
                    createRound(location)
                }
                else if (containerVC.getGadgetFlag() == 7) {
                    createPulley(location)
                }
          
                if (containerVC.getObjectFlag() > 8) {
                    self.selectSprite(nil);
                } else {
                    let objectType = shapeArray[containerVC.getObjectFlag()]
                    let spriteName = String(objectType).lowercaseString
                    let newObj = PWObject.init(objectStringName: spriteName, position: location, isMovable: true, isSelectable: true)
                    objectProperties[newObj] = getParameters(newObj) /**********************************************/
                    self.ObjectIDCounter += 1
                    newObj.setID(self.ObjectIDCounter);
                    containerVC.addObjectToList(newObj.getID())
                    objIdToSprite[newObj.getID()] = newObj;
                    self.addChild(newObj)
                    self.selectSprite(newObj)
                    PWObjects += [newObj]
                }
                continue;
            }
            
            //////////////////////////////////
            //////// APPLY GADGETS ///////////
            //////////////////////////////////
            var sprite: SKNode
            let allNodesInPoint = nodesAtPoint(location)
            for touchedNode:SKNode in allNodesInPoint { // Traverse through all the nodes in the location
                if (PWObject.isPWObject(touchedNode)) {
                    sprite = touchedNode as! PWObject
                }
                 else if (PWStaticObject.isPWStaticObject(touchedNode)) {
                    sprite = touchedNode as! PWStaticObject
                }
                else { continue }

                if (containerVC.getGadgetFlag() < 3) { // Rope
                    if (gadgetNode1 == nil) {
                        gadgetNode1 = sprite
                        if (PWObject.isPWObject(gadgetNode1)) { let n1 = gadgetNode1 as! PWObject;
                            n1.highlight(UIColor.redColor()) }
                    } else if(gadgetNode2 == nil) {
                        gadgetNode2 = sprite
                        if (PWObject.isPWObject(gadgetNode2)) { let n1 = gadgetNode2 as! PWObject;
                            n1.highlight(UIColor.redColor()) }
                        if (gadgetNode1 != gadgetNode2) {
                            if (containerVC.getGadgetFlag() == 0) { createRopeBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                            if (containerVC.getGadgetFlag() == 1) { createSpringBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                            if (containerVC.getGadgetFlag() == 2) { createRodBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                        }
                        if (PWObject.isPWObject(gadgetNode2)) { let n2 = gadgetNode2 as! PWObject; n2.unhighlight() }
                        if (PWObject.isPWObject(gadgetNode1)) { let n1 = gadgetNode1 as! PWObject; n1.unhighlight() }
                        gadgetNode2 = nil;
                        gadgetNode1 = nil;
                    }
                } else {
                    if (PWObject.isPWObject(touchedNode))  {
                    self.selectSprite((sprite as! PWObject));
                    containerVC.changeToObjectInputBox()
                        containerVC.setsInputBox(objectProperties[selectedSprite]!, state: "editable")
                    }
                    else if pwPaused {
                    self.selectGadget((sprite as! PWStaticObject));
                    containerVC.changeToGadgetInputBox(sprite.name!)
                    containerVC.setsGadgetInputBox(selectedGadget.name!, input: gadgetProperties[selectedGadget]!, state: "editable")
                    }
                }
            }
        }
    }
    
    func getObjFromID(ID: Int) -> PWObject {
        let obj = objIdToSprite[ID] as PWObject!
        
        return obj;
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let cameraNodeLocation = cam.convertPoint(location, fromNode: self)
            hideLabels();
            // Removes the selectedShape if it's over the trash bin
            if trash.containsPoint(cameraNodeLocation){
                if selectedSprite != nil {
                    PWObjects.removeAtIndex(PWObjects.indexOf(selectedSprite)!)
                    objectProperties.removeValueForKey(selectedSprite)
                    selectedSprite.removeFromParent()
                    containerVC.removeObjectFromList(selectedSprite.getID())
                    self.selectSprite(nil);
                }
                else if selectedGadget != nil {
                    PWStaticObjects.removeAtIndex(PWStaticObjects.indexOf(selectedGadget)!)
                    // gadgetProperties.removeValueForKey(selectedGadget) need to populate gadget properties
                    selectedGadget.removeFromParent()
                    //containerVC.removeGadgetFromList(selectedGadgetgetID())  implent this
                    self.selectSprite(nil);
                }
            }
            // Removes all non-essential nodes from the gamescene
            if stop.containsPoint(cameraNodeLocation) {
                if Timer != nil {
                // resets the time counter
                Timer.invalidate()
                }
                TimeCounter = 0.0
                containerVC.setsElapsedTime(Float(TimeCounter))
                //unselect objects
                deselectGadget()
                selectSprite(nil)
                for node in self.children {
                    if (node != cam) {
                        node.removeFromParent()
                    }
                }
                pauseWorld()
                PWObjects.removeAll()
                PWStaticObjects.removeAll()
                ropeConnections.removeAll()
                springConnections.removeAll()
                rodConnections.removeAll()
                containerVC.removeAllFromList()
                self.camera?.setScale(1)
                self.camera?.position = camPos
                let floor = PWObject.createFloor(CGSize.init(width: background.size.width, height: 0.01))
                self.addChild(floor)
                self.addChild(self.createBG())
            }
            // Gives the pause play button the ability to pause and play a scene
            if button.containsPoint(cameraNodeLocation) {
                if (!pwPaused) { objectProperties = saveAllObjectProperties() }
                
                // Applies changes made by the user to sprite parameters
                restoreAllobjectProperties(objectProperties)
                
                // Pause / Resume the world
                if (pwPaused)   { resumeWorld() }
                else            { pauseWorld()  }

            }
        }
    }
    
    func resumeWorld() {
        self.Timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timeCounter", userInfo: nil, repeats: true);
        //eventorganizer.resumeEventTimer()
        pwPaused = false;
        let end = containerVC.getEndSetter()
        executeEndSetterArray(end); // Executes the events and starts them.
        self.physicsWorld.speed = 1
        pwPaused = false
        button.texture = SKTexture(imageNamed: "pause.png")
        if (selectedGadget != nil) {
            deselectGadget()
            containerVC.changeToObjectInputBox()
            containerVC.setsInputBox(defaultObjectProperties, state: "static")
        }
        
    }
    func pauseWorld() {
        if Timer != nil {
            self.Timer.invalidate()
        }
        self.physicsWorld.speed = 0
        //eventorganizer.pauseEventTimer()
        objectProperties = saveAllObjectProperties()
        pwPaused = true;
        button.texture = SKTexture(imageNamed: "play.png")
        if selectedSprite != nil {
            containerVC.setsInputBox(objectProperties[selectedSprite]!, state: "editable")
        }
    }
    // counts the
    func timeCounter() {
        TimeCounter += 0.1
        containerVC.setsElapsedTime(Float(TimeCounter))
        
    }
    // Creates conditional events based on the input array.
    func executeEndSetterArray(setterString: [String])
    {
        //if Time ["Time", "value"]
        //if End Parameter ["End-Parameter", "parameter", "value", "object"]
        //if Event ["Event", "event type", "value", "object1", "object2"]
        let ID_TIME         = 0; // Time parameters
        let ID_END_PARAM    = 1; // Refers to any single-type number.
        let ID_EVENT        = 2; // Event refers to any
        var flag = -1;
        
        let type = setterString[0];
        
        if (type == "Time") { flag = ID_TIME }
        if (type == "End-Parameter") { flag = ID_END_PARAM }
        if (type == "Event") { flag = ID_EVENT }
        
        switch flag {
        case ID_TIME:
            if (setterString[1] == "") { return; }
            let timeVal = CGFloat(Double(setterString[1])!)
            eventorganizer.createTimeEvent(timeVal)
        case ID_END_PARAM:
            if (setterString[1] == "") { return; }
            if (setterString[2] == "") { return; }
            if (setterString[3] == "") { return; }
            let param = Int(setterString[1]);
            let val = Float(setterString[2])! * pixelToMetric
            let sprite = objIdToSprite[Int(setterString[3])!]
            eventorganizer.createParameterEvent(sprite!, flag: param!, value: CGFloat(val))
        case ID_EVENT:
            if (setterString[3] == "") { return; }
            if (setterString[4] == "") { return; }
            let sprite1 = objIdToSprite[Int(setterString[3])!]
            let sprite2 = objIdToSprite[Int(setterString[4])!]
            eventorganizer.createCollisionEvent(sprite1!, sprite2: sprite2!);
        default:
            return;
        }
    }

    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {        // continously update values of parameters for selected object
        // Checks if there are any parameter events that need checking
        // and checks them.
        eventorganizer.checkParameterEventTriggered();
       // updateFrameCounter += 1
       // if (updateFrameCounter % 5 == 0) {
            if selectedSprite != nil && !pwPaused  {
                containerVC.setsInputBox(getParameters(selectedSprite), state: "static")
              }
       //      }
        if !containerVC.tableAreOpen() {
            if containerVC.TableVC != nil {
         containerVC.TableVC.currentlySelected = NSIndexPath()
            }
        }
            // updates selected shapes values with input box values when pwPaused
        if (selectedSprite != nil && pwPaused) {
                var values = objectProperties[selectedSprite]!
                let input = containerVC.getInput()
                for i in 0 ..< 10 {
                    if (Float(input[i]) != nil) { values[i] = Float(input[i])! }
                }
                objectProperties[selectedSprite] = values
                restoreAllobjectProperties(objectProperties)
            }
            
        else if (selectedGadget != nil && pwPaused) {
            var values = gadgetProperties[selectedGadget]!
            let input = containerVC.getGadgetInput(selectedGadget.name!)
            for i in 0 ..< values.count {
                if (Float(input[i]) != nil) { values[i] = Float(input[i])! }
            }
            gadgetProperties[selectedGadget] = values
            applyAllGadgetProperties(gadgetProperties, forallobjects: false)
        }
        // apply accelerations to objects (constant force)
        for object in self.children {
            if (!PWObject.isPWObject(object)) { continue };
            let sprite = object as! PWObject
            let xComponent = CGFloat(objectProperties[sprite]![shapePropertyIndex.AX.rawValue]*pixelToMetric);
            let yComponent = CGFloat(objectProperties[sprite]![shapePropertyIndex.AY.rawValue]*pixelToMetric);
            sprite.applyAcceleration(xComponent, y: yComponent)
            
            let xComponentForce = CGFloat(objectProperties[sprite]![shapePropertyIndex.FX.rawValue]*pixelToMetric);
            let yComponentForce = CGFloat(objectProperties[sprite]![shapePropertyIndex.FY.rawValue]*pixelToMetric);
            sprite.applyForce(xComponentForce, y: yComponentForce)
        }
        updateSprings();
        if selectedSprite != nil && !pwPaused {
            self.camera!.position = boundedCamMovement(selectedSprite.position)
        }
    }

    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.position.y < 0 { node.removeFromParent() }
        })
    }

    // Allows users to drag and drop selectedShapes and the background
    func panForTranslation(translation: CGPoint) {
        updateNodeLabels()
        if selectedSprite != nil {
            let position = selectedSprite.position
            if selectedSprite.isMovable() {
                selectedSprite.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                containerVC.setsInputBox(getParameters(selectedSprite), state: "editable")
            }
        }
            else if selectedGadget != nil {
                    let position = selectedGadget.position
                    if selectedGadget.isMovable() {
                        selectedGadget.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                        containerVC.setsGadgetInputBox(selectedGadget.name!, input:getGadgetParameters(selectedGadget), state: "editable")
                    }
        }
        else {
            let newPosition = CGPoint(x: self.camera!.position.x - translation.x, y: self.camera!.position.y - translation.y)
            self.camera!.position = boundedCamMovement(newPosition)
        }
    }
    
    // Makes it so that the user can't pan outside the screen.
    func boundedCamMovement(newPosition: CGPoint) -> CGPoint {
        
        var retval = newPosition
        
        let lower_bg_x = background.position.x
        let upper_bg_x = background.position.x + background.size.width
        let lower_bg_y = background.position.y
        let upper_bg_y = background.position.y + background.size.height
        
        let lower_cam_x = newPosition.x - (self.size.width * (self.camera?.xScale)!)/2
        let upper_cam_x = newPosition.x + (self.size.width * (self.camera?.xScale)!)/2
        let lower_cam_y = newPosition.y - (self.size.height * (self.camera?.yScale)!)/2
        let upper_cam_y = newPosition.y + (self.size.height * (self.camera?.yScale)!)/2
        
        if (lower_cam_x < lower_bg_x) { retval.x = lower_bg_x + (self.size.width * (self.camera?.xScale)!)/2 }
        if (upper_cam_x > upper_bg_x) { retval.x = upper_bg_x - (self.size.width * (self.camera?.xScale)!)/2 }
        if (lower_cam_y < lower_bg_y) { retval.y = lower_bg_y + (self.size.height * (self.camera?.yScale)!)/2 }
        if (upper_cam_y > upper_bg_y) { retval.y = upper_bg_y - (self.size.height * (self.camera?.yScale)!)/2 }
        
        return retval
    }
    
    
    // This function is called if an event has been triggered
    func eventTriggered(event: Event) {
        pauseWorld()
        Timer.invalidate()
        if (event.isCollisionEvent()) {
            let sprites = event.getSprites();
            print(String(sprites![0].getID()) + " has collided with " + String(sprites![1].getID));
        }
        if (event.isTimerEvent()) {
            print("Timer occured!");
        }
        
        if (event.isPropertyEvent()) {
            let s = event.getCurrentPropertyValue();
            print("Property exceeded: " + String(s));
        }
        eventorganizer.deleteEvent();
    }
    
    // Makes sure the user can only drag objects when the simulation is paused and sets up for panForTranslation
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch?.locationInNode(self)
        let previousPosition = touch?.previousLocationInNode(self)
        let translation = CGPoint(x: positionInScene!.x - previousPosition!.x, y: positionInScene!.y - previousPosition!.y)
        if pwPaused {
            panForTranslation(translation)
        }
    }
    
    // Allows the user to zoom in and out of the scene.
    var cameraScale: CGFloat = 1.0
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Changed {
            // Location of the corner points of the background.
            let lower_bg_x = background.position.x
            let upper_bg_x = background.position.x + background.size.width
            let lower_bg_y = background.position.y
            let upper_bg_y = background.position.y + background.size.height
            
            // Location of the corner points of the camera.
            let lower_cam_x = (self.camera?.position.x)! - (self.size.width * cameraScale / recognizer.scale)/2
            let upper_cam_x = (self.camera?.position.x)! + (self.size.width * cameraScale / recognizer.scale)/2
            let lower_cam_y = (self.camera?.position.y)! - (self.size.height * cameraScale / recognizer.scale)/2
            let upper_cam_y = (self.camera?.position.y)! + (self.size.height * cameraScale / recognizer.scale)/2
            
            // Bound zoom to background size.
            if (lower_cam_x < lower_bg_x) { return }
            if (upper_cam_x > upper_bg_x) { return }
            if (lower_cam_y < lower_bg_y) { return }
            if (upper_cam_y > upper_bg_y) { return }
            
            // Handle scaling functions.
            cameraScale /= recognizer.scale
            self.camera?.setScale(cameraScale);
            recognizer.scale = 1.0;
        }
    }
    
    // Saves the sprites that are currently in the scene
    func saveSprites(saveNumber: Int) {
        var isSuccessfulSave = false
        var isSuccessfulSaveS = false
        
        if saveNumber == 1 {
            isSuccessfulSave = NSKeyedArchiver.archiveRootObject(PWObjects, toFile: PWObject.ArchiveURL1.path!)
            isSuccessfulSaveS = NSKeyedArchiver.archiveRootObject(PWStaticObjects, toFile: PWStaticObject.ArchiveURLS1.path!)
            
            // Stores data for ropes
            let dataSave = NSKeyedArchiver.archivedDataWithRootObject(ropeConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "ropeConnections1")
            
            // Stores data for springs
            let dataSaveSpring = NSKeyedArchiver.archivedDataWithRootObject(springConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSaveSpring, forKey: "springConnections1")
            
            // Stores data for Rods
            let dataSaveRod = NSKeyedArchiver.archivedDataWithRootObject(rodConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSaveRod, forKey: "rodConnections1")
        }
        if saveNumber == 2 {
            isSuccessfulSave = NSKeyedArchiver.archiveRootObject(PWObjects, toFile: PWObject.ArchiveURL2.path!)
            isSuccessfulSaveS = NSKeyedArchiver.archiveRootObject(PWStaticObjects, toFile: PWStaticObject.ArchiveURLS2.path!)
            
            // Stores data for ropes
            let dataSave = NSKeyedArchiver.archivedDataWithRootObject(ropeConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "ropeConnections2")
            
            // Stores data for springs
            let dataSaveSpring = NSKeyedArchiver.archivedDataWithRootObject(springConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSaveSpring, forKey: "springConnections2")
            
            // Stores data for Rods
            let dataSaveRod = NSKeyedArchiver.archivedDataWithRootObject(rodConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSaveRod, forKey: "rodConnections2")
        }
        if saveNumber == 3 {
            isSuccessfulSave = NSKeyedArchiver.archiveRootObject(PWObjects, toFile: PWObject.ArchiveURL3.path!)
            isSuccessfulSaveS = NSKeyedArchiver.archiveRootObject(PWStaticObjects, toFile: PWStaticObject.ArchiveURLS3.path!)
            
            // Stores data for ropes
            let dataSave = NSKeyedArchiver.archivedDataWithRootObject(ropeConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSave, forKey: "ropeConnections3")
            
            // Stores data for springs
            let dataSaveSpring = NSKeyedArchiver.archivedDataWithRootObject(springConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSaveSpring, forKey: "springConnections3")
            
            // Stores data for Rods
            let dataSaveRod = NSKeyedArchiver.archivedDataWithRootObject(rodConnections)
            NSUserDefaults.standardUserDefaults().setObject(dataSaveRod, forKey: "rodConnections3")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Prints out to the log if saving isn't successful
        if !isSuccessfulSave {
            print("Failed to save PWObjects.")
        }
        if !isSuccessfulSaveS {
            print("Failed to save PWStaticObjects")
        }
    }
    
    // Loads the sprites from hardware memory
    func loadSprites(loadFileNumber: Int) -> [PWObject]? {
        var loadArray: [PWObject]?
        
        if loadFileNumber == 1 {
            loadArray = NSKeyedUnarchiver.unarchiveObjectWithFile(PWObject.ArchiveURL1.path!) as? [PWObject]
        }
        if loadFileNumber == 2 {
            loadArray = NSKeyedUnarchiver.unarchiveObjectWithFile(PWObject.ArchiveURL2.path!) as? [PWObject]
        }
        if loadFileNumber == 3 {
            loadArray = NSKeyedUnarchiver.unarchiveObjectWithFile(PWObject.ArchiveURL3.path!) as? [PWObject]
        }
        
        return loadArray
    }
    
    // Loads static sprites from hardware memory
    func loadStaticSprites(loadFileNumber: Int) -> [PWStaticObject]? {
        var loadStaticArray: [PWStaticObject]?
        
        if loadFileNumber == 1 {
            loadStaticArray = NSKeyedUnarchiver.unarchiveObjectWithFile(PWStaticObject.ArchiveURLS1.path!) as? [PWStaticObject]
        }
        if loadFileNumber == 2 {
            loadStaticArray = NSKeyedUnarchiver.unarchiveObjectWithFile(PWStaticObject.ArchiveURLS2.path!) as? [PWStaticObject]
        }
        if loadFileNumber == 3 {
            loadStaticArray = NSKeyedUnarchiver.unarchiveObjectWithFile(PWStaticObject.ArchiveURLS3.path!) as? [PWStaticObject]
        }
        
        return loadStaticArray
    }
    
    // Loads data that the user saves earlier
    func loadSave(loadFileNumber: Int) {
        // Deletes all objects and sets the scene
        for node in self.children {
            if (node != cam) {
                node.removeFromParent()
            }
        }
        // reset time counter
        TimeCounter = 0
        containerVC.setsElapsedTime(Float(TimeCounter))
        selectedSprite = nil
        PWObjects.removeAll()
        PWStaticObjects.removeAll()
        containerVC.removeAllFromList()
        let floor = PWObject.createFloor(CGSize.init(width: background.size.width, height: 0.01))
        self.addChild(floor)
        self.addChild(self.createBG())
        
        // Retrieves saved arrays of nodes that are connected by ropes, springs, or rods
        var savedRopeNodes = [SKNode]?()
        var savedSpringNodes = [SKNode]?()
        var savedRodNodes = [SKNode]?()
        
        // Loads ropes, springs, and rods into the scene.
        if loadFileNumber == 1 {
            if let savedRopeData = NSUserDefaults.standardUserDefaults().valueForKey("ropeConnections1") as? NSData {
                savedRopeNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedRopeData) as? [SKNode]
            }
            
            if let savedSpringData = NSUserDefaults.standardUserDefaults().valueForKey("springConnections1") as? NSData {
                savedSpringNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedSpringData) as? [SKNode]
            }
            
            if let savedRodData = NSUserDefaults.standardUserDefaults().valueForKey("rodConnections1") as? NSData {
                savedRodNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedRodData) as? [SKNode]
            }
        }
        if loadFileNumber == 2 {
            if let savedRopeData = NSUserDefaults.standardUserDefaults().valueForKey("ropeConnections2") as? NSData {
                savedRopeNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedRopeData) as? [SKNode]
            }
            
            if let savedSpringData = NSUserDefaults.standardUserDefaults().valueForKey("springConnections2") as? NSData {
                savedSpringNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedSpringData) as? [SKNode]
            }
            
            if let savedRodData = NSUserDefaults.standardUserDefaults().valueForKey("rodConnections2") as? NSData {
                savedRodNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedRodData) as? [SKNode]
            }
        }
        if loadFileNumber == 3 {
            if let savedRopeData = NSUserDefaults.standardUserDefaults().valueForKey("ropeConnections3") as? NSData {
                savedRopeNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedRopeData) as? [SKNode]
            }
            
            if let savedSpringData = NSUserDefaults.standardUserDefaults().valueForKey("springConnections3") as? NSData {
                savedSpringNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedSpringData) as? [SKNode]
            }
            
            if let savedRodData = NSUserDefaults.standardUserDefaults().valueForKey("rodConnections3") as? NSData {
                savedRodNodes = NSKeyedUnarchiver.unarchiveObjectWithData(savedRodData) as? [SKNode]
            }
        }
        
        // Saves PWObjects
        if let savedSprites = loadSprites(loadFileNumber) {
            for obj in savedSprites {
                var values = [Float]()
                values.append(Float(obj.getMass()))
                values.append(Float(obj.getPos().x)/pixelToMetric)
                values.append(Float(obj.getPos().y)/pixelToMetric)
                values.append(Float(obj.getVelocity().dx)/pixelToMetric)
                values.append(Float(obj.getVelocity().dy)/pixelToMetric)
                values.append(Float(obj.getAngularVelocity()))
                values.append(Float(obj.getAcceleration().dx))
                values.append(Float(obj.getAcceleration().dy))
                values.append(Float(obj.getForce().dx))
                values.append(Float(obj.getForce().dy))
                
                self.ObjectIDCounter += 1
                obj.setID(self.ObjectIDCounter);
                containerVC.addObjectToList(obj.getID())
                objIdToSprite[obj.getID()] = obj;
                
                objectProperties[obj] = values
                PWObjects += [obj]
                self.addChild(obj)
                
                for var i = 0; i < savedRopeNodes!.count; i++ {
                    if savedRopeNodes![i].isEqualToNode(obj) {
                        savedRopeNodes![i] = obj
                    }
                }
                
                for var i = 0; i < savedSpringNodes!.count; i++ {
                    if savedSpringNodes![i].isEqualToNode(obj) {
                        savedSpringNodes![i] = obj
                    }
                }
                
                for var i = 0; i < savedRodNodes!.count; i++ {
                    if savedRodNodes![i].isEqualToNode(obj) {
                        savedRodNodes![i] = obj
                    }
                }
            }
        }
        
        // Saves PWStaticObjects
        if let savedStaticSprites = loadStaticSprites(loadFileNumber) {
            for obj in savedStaticSprites {
                gadgetProperties[obj] = obj.values
                
                for var i = 0; i < savedRopeNodes!.count; i++ {
                    if savedRopeNodes![i].isEqualToNode(obj) {
                        savedRopeNodes![i] = obj
                    }
                }
                
                for var i = 0; i < savedSpringNodes!.count; i++ {
                    if savedSpringNodes![i].isEqualToNode(obj) {
                        savedSpringNodes![i] = obj
                    }
                }
                
                for var i = 0; i < savedRodNodes!.count; i++ {
                    if savedRodNodes![i].isEqualToNode(obj) {
                        savedRodNodes![i] = obj
                    }
                }
            
                applyAllGadgetProperties(gadgetProperties, forallobjects: true)
                PWStaticObjects += [obj]
                self.addChild(obj)
            }
        }

        // Creates the rope, spring, and rod connections between nodes that were saved with those connections
        if savedRopeNodes != nil {
            for var i = 0; i < savedRopeNodes!.count; i += 2 {
                createRopeBetweenNodes(savedRopeNodes![i], node2: savedRopeNodes![i+1])
            }
        }
        
        if savedSpringNodes != nil {
            for var i = 0; i < savedSpringNodes!.count; i += 2 {
                createSpringBetweenNodes(savedSpringNodes![i], node2: savedSpringNodes![i+1])
            }
        }
        
        if savedRodNodes != nil {
            for var i = 0; i < savedRodNodes!.count; i += 2 {
                createRodBetweenNodes(savedRodNodes![i], node2: savedRodNodes![i+1])
            }
        }
    }
}