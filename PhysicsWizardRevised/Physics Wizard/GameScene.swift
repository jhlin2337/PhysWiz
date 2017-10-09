//
//  GameScene.swift
//  Physics Wizard
//
//  Created by James Lin on 1/30/17.
//  Copyright © 2017 James Lin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let NAVIGATIONBAR_HEIGHT: CGFloat = 40
    let OBJECT_START_SIZE: CGFloat = 40
    let BOUNDARY_THICKNESS: CGFloat = 5
    
    let cam = SKCameraNode()
    
    var background: SKSpriteNode! = nil
    var pausePlayButton: SKSpriteNode! = nil
    var stopButton: SKSpriteNode! = nil
    var trashbin: SKSpriteNode! = nil
    
    var selectedObject = SKNode()
    var selectedMenuObject = "circle.png"
    
    override func didMove(to view: SKView) {
        self.setupSimulation()
    }
    
    /******************************************** SCAFFOLDING CODE ********************************************/
    func createBall(position: CGPoint) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "circle.png")

        ball.position = position
        ball.name = "ball"
        ball.size = diameterToCGSize(diameter: 40)
        
        ball.physicsBody = SKPhysicsBody(texture: SKTexture.init(imageNamed: "circle.png"), size: ball.size)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.restitution = 0.7
        
        return ball
    }
    /******************************************** SCAFFOLDING CODE ********************************************/
    
    
    
    
    /************************************************ STAGE 1 CODE ************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location:CGPoint = touch.location(in: self)
            
            if (pointIsValid(location: location)) {
                createObject(objectPosition: location)
            }
            
            selectNodeForTouch(touchLocation: location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let locationInCamera = cam.convert(location, from: self)
            
            // Pause or play the simulation
            if (pausePlayButton.contains(locationInCamera)) {
                if (self.simulationIsPaused()) { self.resumeSimulation() }
                else { self.pauseSimulation() }
            }
            
            // Stops and resets the simulation
            if (stopButton.contains(locationInCamera)) {
                self.resetSimulation()
            }
            
            // Deletes node if dropped into trashbin
            if (trashbin.contains(cam.convert(selectedObject.position, from: self))) {
                selectedObject.removeFromParent()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let positionInScene = touch.location(in: self)
            let previousPosition = touch.previousLocation(in: self)
            let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
        
            if (self.simulationIsPaused()) {
                moveNodes(translation: translation)
            }
        }
    }
    
    // Bounds the camera node to within the confines of the simulation
    func boundedCameraPosition(newCameraPosition: CGPoint) -> CGPoint {
        var retval = newCameraPosition
        
        let lower_bg_x: CGFloat = 0
        let lower_cam_x = newCameraPosition.x - (self.size.width * (self.camera?.xScale)!)/2
        if (lower_cam_x < lower_bg_x) { retval.x = lower_bg_x + (self.size.width * (self.camera?.xScale)!)/2 }
        
        let upper_bg_x = 5 * self.frame.size.width
        let upper_cam_x = newCameraPosition.x + (self.size.width * (self.camera?.xScale)!)/2
        if (upper_cam_x > upper_bg_x) { retval.x = upper_bg_x - (self.size.width * (self.camera?.xScale)!)/2 }
        
        let lower_bg_y: CGFloat = 0
        let lower_cam_y = newCameraPosition.y - (self.size.height * (self.camera?.yScale)!)/2
        if (lower_cam_y < lower_bg_y) { retval.y = lower_bg_y + (self.size.height * (self.camera?.yScale)!)/2 }
        
        let upper_bg_y = 5 * self.frame.size.height
        let upper_cam_y = newCameraPosition.y + (self.size.height * (self.camera?.yScale)!)/2
        if (upper_cam_y > upper_bg_y) { retval.y = upper_bg_y - (self.size.height * (self.camera?.yScale)!)/2 }
        
        return retval
    }
    /************************************************ STAGE 1 CODE ************************************************/
    
    
    
    
    /************************************************ STAGE 2 CODE ************************************************/
    func createObject(objectPosition: CGPoint) {
        let dynamicObjectStringNames = ["circle.png", "square.png", "triangle.png"]
        let staticObjectStringNames = ["circle", "rectangle", "triangle"]
        let objectName = getSelectedMenuObject()
        let objectSize = diameterToCGSize(diameter: OBJECT_START_SIZE)
        
        if dynamicObjectStringNames.contains(objectName) {
            createDynamicObject(objectName: objectName, objectPosition: objectPosition, objectSize: objectSize)
        } else if staticObjectStringNames.contains(objectName) {
            createStaticObject(objectName: objectName, objectPosition: objectPosition, objectSize: objectSize)
        } else {
            return
        }
    }
    
    // Consider adding objectSize and changing objectName to an enum of possible sprites
    func createDynamicObject(objectName: String, objectPosition: CGPoint, objectSize: CGSize) {
        let objectTexture = SKTexture.init(imageNamed: objectName)
        
        let dynamicObject = PWDynamicObject(objectTexture: objectTexture, objectPosition: objectPosition, objectSize: objectSize)
        self.addChild(dynamicObject)
    }
    
    func createStaticObject(objectName: String, objectPosition: CGPoint, objectSize: CGSize) {
        let staticObject = PWStaticObject(objectName: objectName, objectPosition: objectPosition, objectSize: objectSize)
        self.addChild(staticObject)
    }
    
    // Returns a boolean indicating whether or not the simulation is paused
    func simulationIsPaused() -> Bool {
        return self.isPaused
    }
    
    // Pauses the simulation
    func pauseSimulation() {
        self.isPaused = true
        pausePlayButton.texture = SKTexture(imageNamed: "play.png")
    }
    
    // Resumes the simulation
    func resumeSimulation() {
        self.isPaused = false
        pausePlayButton.texture = SKTexture(imageNamed: "pause.png")
    }
    
    // Resets everything in the simulation
    func resetSimulation() {
        self.cam.removeAllChildren()
        self.scene?.removeAllChildren()
        self.setupSimulation()
    }

    // Is the node the pause play button, stop button, or trashbin?
    func nodeIsIcon(node: SKNode) -> Bool {
        return (node.name == "pausePlayButton") || (node.name == "stopButton") || (node.name == "trashbin")
    }
    
    // Is the node a boundary node?
    func nodeIsBoundary(node: SKNode) -> Bool {
        return (node.name == "floor") || (node.name == "ceiling") || (node.name == "leftWall") || (node.name == "rightWall")
    }
    
    // Is the selected object a dynamic object?
    func selectedObjectIsMovable() -> Bool {
        if selectedObject.name != nil {
            if selectedObject.name! == "dynamicObject" || selectedObject.name! == "staticObject" { return true }
        }
        return false
    }
    
    // Sets the node at touchLocation to be the selectedObject
    func selectNodeForTouch(touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        deselectSelectedObject()
        
        if touchedNode is SKSpriteNode {
            if ((!self.nodeIsIcon(node: touchedNode)) && (!self.nodeIsBoundary(node: touchedNode))) {
                selectedObject = touchedNode as! SKSpriteNode
            }
        }
        if touchedNode is SKShapeNode {
            if ((!self.nodeIsIcon(node: touchedNode)) && (!self.nodeIsBoundary(node: touchedNode))) {
                selectedObject = touchedNode as! SKShapeNode
            }
        }
    }
    
    // Deselects the object that's currently referenced by the sprite selectedObject
    func deselectSelectedObject() {
        selectedObject = SKNode()
    }
    
    // Allows users to drag movable nodes around the screen. This includes the camera node.
    func moveNodes(translation: CGPoint) {
        if selectedObjectIsMovable() {
            let position = selectedObject.position
            selectedObject.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        } else {
            let position = self.camera!.position
            let newCameraPosition = CGPoint(x: position.x - translation.x, y: position.y - translation.y)
            self.camera!.position = self.boundedCameraPosition(newCameraPosition: newCameraPosition)
        }
    }
    
    // Sets the object that will be created when the screen is tapped
    func setSelectedMenuObject(objectName: String) {
        selectedMenuObject = objectName
    }
    
    // Returns the object that will be created when the screen is tapped
    func getSelectedMenuObject() -> String {
        return selectedMenuObject
    }
    /************************************************ STAGE 2 CODE ************************************************/
    
    
    
    
    /************************************************ STAGE 3 CODE ************************************************/
    // Sets up the camera node for the gamescene.
    func setupCamera() {
        self.addChild(self.cam)
        self.camera = cam
        let startingCameraPosition = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.camera?.position = startingCameraPosition
        cam.name = "camera"
    }
    
    // Sets up everything in the gamescene
    func setupSimulation() {
        self.isPaused = true
        self.setupCamera()
        self.createBackground()
        self.createPausePlayButton()
        self.createStopButton()
        self.createTrashbin()
        self.createBoundaries()
    }
    
    // Checks if there is an object at location. If there is returns false, if there isn't returns true.
    func pointIsValid(location: CGPoint) -> Bool {
        let nodes = self.nodes(at: location)
        for node in nodes {
            if (self.nodeIsIcon(node: node)) { return false }
            if (self.nodeIsBoundary(node: node)) { return false }
            if (node.name == "dynamicObject") { return false }
            if (node.name == "staticObject") { return false }
        }
        
        return true
    }
    /************************************************ STAGE 3 CODE ************************************************/
    
    
    
    
    /********************************************* FINAL RELEASE CODE *********************************************/
    // Creates a background for the gamescene.
    func createBackground() {
        backgroundColor = SKColor.white
    }
    
    // Creates a node that will act as a pause play button for the user.
    func createPausePlayButton() {
        let buttonDiameter = self.size.height/10
        
        pausePlayButton = SKSpriteNode(imageNamed: "play.png")
        pausePlayButton.name = "pausePlayButton"
        pausePlayButton.size = diameterToCGSize(diameter: buttonDiameter)
        
        pausePlayButton.position.x = (self.camera!.position.x - (self.camera!.position.x/10))
        pausePlayButton.position.y = (self.camera!.position.y - (self.camera!.position.x/10) - NAVIGATIONBAR_HEIGHT)
        pausePlayButton.zPosition = 1
        
        cam.addChild(pausePlayButton)
    }
    
    // Creates a node that will act as a stop button for the user.
    func createStopButton() {
        let buttonDiameter = self.size.height/10
        
        stopButton = SKSpriteNode(imageNamed: "stop.png")
        stopButton.name = "stopButton"
        stopButton.size = diameterToCGSize(diameter: buttonDiameter)
        
        stopButton.position.x = (pausePlayButton.position.x - (pausePlayButton.size.width/2) - (self.camera!.position.x/10))
        stopButton.position.y = (self.camera!.position.y - (self.camera!.position.x/10) - NAVIGATIONBAR_HEIGHT)
        stopButton.zPosition = 1
        
        cam.addChild(stopButton)
    }
    
    // Creates a trash bin for users to delete unwanted objects with
    func createTrashbin() {
        let iconDiameter = self.size.height/8
        
        trashbin = SKSpriteNode(imageNamed: "trash.png")
        trashbin.name = "trashbin"
        trashbin.size = diameterToCGSize(diameter: iconDiameter)
        
        trashbin.position.x = (self.camera!.position.x - (self.camera!.position.x/10))
        trashbin.position.y = self.camera!.position.x/10 - self.camera!.position.y
        trashbin.zPosition = -1
        
        cam.addChild(trashbin)
    }
    
    // Creates a floor, a ceiling, and walls on each side to that bounds the simulation
    func createBoundaries() {
        let simulationScreenWidth = 5 * self.frame.size.width
        let simulationScreenHeight = 5 * self.frame.size.height
        
        createFloor(simulationWidth: simulationScreenWidth)
        createCeiling(simulationWidth: simulationScreenWidth, simulationHeight: simulationScreenHeight)
        createLeftWall(simulationHeight: simulationScreenHeight)
        createRightWall(simulationWidth: simulationScreenWidth, simulationHeight: simulationScreenHeight)
    }
    
    // Bounds the lowest point that an object in the simulation can go
    func createFloor(simulationWidth: CGFloat) {
        let floor = SKSpriteNode(color: SKColor.brown, size: CGSize(width: simulationWidth, height: BOUNDARY_THICKNESS))
        
        floor.anchorPoint = CGPoint(x: 0, y: 0)
        floor.name = "floor"
        floor.position = CGPoint.zero
        
        floor.physicsBody = SKPhysicsBody(edgeLoopFrom: floor.frame)
        floor.physicsBody?.isDynamic = false
        
        self.addChild(floor)
    }
    
    // Bounds the highest point that an object in the simulation can go
    func createCeiling(simulationWidth: CGFloat, simulationHeight: CGFloat) {
        let ceiling = SKSpriteNode(color: SKColor.brown, size: CGSize(width: simulationWidth, height: BOUNDARY_THICKNESS))
        
        ceiling.anchorPoint = CGPoint(x: 0, y: 0)
        ceiling.name = "ceiling"
        ceiling.position = CGPoint(x: 0, y: simulationHeight)
        
        ceiling.physicsBody = SKPhysicsBody(edgeLoopFrom: ceiling.frame)
        ceiling.physicsBody?.isDynamic = false
        
        self.addChild(ceiling)
    }
    
    // Bounds the leftmost point that an object in the simulation can go
    func createLeftWall(simulationHeight: CGFloat) {
        let leftWall = SKSpriteNode(color: SKColor.brown, size: CGSize(width: BOUNDARY_THICKNESS, height: simulationHeight))
        
        leftWall.anchorPoint = CGPoint(x: 0,  y: 0)
        leftWall.name = "leftWall"
        leftWall.position = CGPoint.zero
        
        leftWall.physicsBody = SKPhysicsBody(edgeLoopFrom: leftWall.frame)
        leftWall.physicsBody?.isDynamic = false
        
        self.addChild(leftWall)
    }
    
    // Bounds the rightmost point that an object in the simulation can go
    func createRightWall(simulationWidth: CGFloat, simulationHeight: CGFloat) {
        let rightWall = SKSpriteNode(color: SKColor.brown, size: CGSize(width: BOUNDARY_THICKNESS, height: simulationHeight))
        
        rightWall.anchorPoint = CGPoint(x: 0, y: 0)
        rightWall.name = "rightWall"
        rightWall.position = CGPoint(x: simulationWidth - BOUNDARY_THICKNESS, y: 0)
        
        rightWall.physicsBody = SKPhysicsBody(edgeLoopFrom: rightWall.frame)
        rightWall.physicsBody?.isDynamic = false
        
        self.addChild(rightWall)
    }
    
    // Given a radius, returns a CGSize with width and height set to radius.
    func diameterToCGSize(diameter: CGFloat) -> CGSize {
        return CGSize(width: diameter, height: diameter)
    }
    /********************************************* FINAL RELEASE CODE *********************************************/
}
