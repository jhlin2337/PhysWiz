//
//  PWObject.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/11/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
// Class that represents each actual sprite object in the scene.
// This will contain acceleration, velocity, force, and other
// important object properties that will facilitate in
// solving the physics problems.

import Foundation
import SpriteKit


// String to its object type representation
// This is what will be passed in when we want to create
// a new object. Each enumeration defines the types of objects
// that the user can create in the GameScene.
enum shapeType: String {
    case CIRCLE     = "circle"
    case SQUARE     = "square"
    case TRIANGLE   = "triangle"
    case CRATE      = "crate"
    case BASEBALL   = "baseball"
    case BRICKWALL  = "brickwall"
    case AIRPLANE   = "airplane"
    case BIKE       = "bike"
    case CAR        = "car"
    case BUTTON     = "button"
    case FLOOR      = "floor"
}


class PWObject: SKSpriteNode
{
    var skObj: SKSpriteNode?
    
    // False if the static class has been initialized, meaning that
    // the object texture map has been populated.
    private static var hasStaticBeenInit = false;
    
    // This static dictionary contains the map from the string
    // representation of an object to the string file name of the
    // texture that will reprsent it.
    // Example: "ball" will refer to "ball.png" which will later
    // be used to actually apply the texture for the object.
    private static var objectTextureMap = [String: String]()
    
    // Color of the highlights around selected nodes.
    private static var standardHighlightColor = UIColor.blueColor()
    
    // Flag that will determine if this object can be moved by the
    // game scene
    private var metricScale         = 100   // Factor to convert pixel units to metric units
    private var objectID            = -1    // Unique ID Assigned to each sprite.
    private var selected            = true  // Flag that determines if the object is selected by the scene.
    private var glowNode: SKShapeNode?      // The node representing the glow of this object.
    private var acceleration: CGVector
    private var force: CGVector
    
    var objectStringName: String
    var objectPosition: CGPoint
    var movable: Bool       = true
    var selectable: Bool    = true
    
    static let DocumentsDirectory1 = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL1 = DocumentsDirectory1.URLByAppendingPathComponent("save1")
    
    static let DocumentsDirectory2 = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL2 = DocumentsDirectory2.URLByAppendingPathComponent("save2")
    
    static let DocumentsDirectory3 = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL3 = DocumentsDirectory3.URLByAppendingPathComponent("save3")
    
    
    // This initializes the static variables if it hasn't been initialized yet.
    // This MUST be called when at least one instance of the PWObject
    // has been created.
    static func initStaticVariables()
    {
        if (hasStaticBeenInit) { return }
        hasStaticBeenInit = true;
        
        objectTextureMap["circle"]      = "circle.png"
        objectTextureMap["square"]      = "square.png"
        objectTextureMap["triangle"]    = "triangle.png"
        objectTextureMap["crate"]       = "crate.png"
        objectTextureMap["baseball"]    = "baseball.png"
        objectTextureMap["brickwall"]   = "brickwall.png"
        objectTextureMap["airplane"]    = "airplane.png"
        objectTextureMap["bike"]        = "bike.png"
        objectTextureMap["car"]         = "car.png"
        objectTextureMap["button"]      = "button.png"
        objectTextureMap["floor"]       = "floor.png"
    }
    
    // Returns the string name of the image texture that represents
    // the object. Returns nil if the texture name is not in the
    // dictionary.
    static func getObjectTextureName(objectName: String) -> String!
    {
        let val = objectTextureMap[objectName]
        if (val != nil) {
            return val
        } else {
            return nil
        }
    }
    
    // Checks if the object name exists as a PWObject.
    // Returns true if it does, otherwise it returns false.
    static func doesObjectExist(objectName: String) -> Bool
    {
        if (objectTextureMap[objectName]) != nil {
            return true
        } else {
            return false
        }
    }
    
    // ##############################################################
    //
    //  Flag functions belong here! Implement all the functions
    //  that call to or write to a flag variable here.
    //
    // ##############################################################
    
    
    // Makes this node movable by setting the movable flag to true.
    // This will allow the user to be able to move the object.
    func makeMovable() {
        self.movable = true;
    }
    
    // Makes this node selectable by setting the selectable flag to true.
    // This will allow the user to be able to select the object.
    // Selecting the object allows the user to see its properties
    func makeSelectable() {
        self.movable = true;
    }
    
    // Makes this node movable by setting the movable flag to true.
    // This will allow the user to be able to move the object.
    func isMovable() -> Bool {
        return self.movable;
    }
    
    // Makes this node selectable by setting the selectable flag to true.
    // This will allow the user to be able to move the object.
    func isSelectable() -> Bool {
        return self.selectable;
    }
    
    // Checks if the PWObject is a sprite (i.e. any shape that will
    // contain physical properties).
    func isSprite() -> Bool {
        return self.movable;
    }
    
    // Returns the unique object ID
    func getID() -> Int {
        return self.objectID;
    }
    
    // Sets the unique object ID
    func setID(id: Int) {
        self.objectID = id;
    }
    
    // Signifies that this object is selected in the game scene.
    func setSelected() {
        self.highlight(PWObject.standardHighlightColor)
        self.selected = true;
    }
    
    // Unselects the object in the game scene.
    // Also unhighlights it.
    func setUnselected() {
        self.unhighlight()
        self.selected = false;
    }
    
    // Checks if this object's flag is currently represented as selected.
    // Also highlights it.
    func isSelected() -> Bool {
        return self.selected;
    }
    
    
    // ##############################################################
    //
    //  Parameter functions belong here! Implement all the functions
    //  that call for or modify specific parameters that are not native to
    //  spritekit (Acceleration, Moment of Inertia, Rotational Accel.
    //
    // ##############################################################
    
    // Object numerical properties
    func setPos(position: CGPoint)
    {
        self.position = position
        objectPosition = position
    }
    
    func setPos(x: CGFloat, y: CGFloat)
    {
        self.position = CGPointMake(x, y)
        objectPosition = CGPointMake(x, y)
    }
    
    func getPos() -> CGPoint { return self.position; }
    
    func setMass(mass: CGFloat) {
        if (mass < 0.10) { self.physicsBody?.mass = 0.10 } // This is the abs min of mass
        else { self.physicsBody?.mass = mass }
    }
    func getMass() -> CGFloat
    {
        if self.physicsBody?.mass == nil {
            return 1.0
        }
        return (self.physicsBody?.mass)!
    }
    
    func setFriction(friction: CGFloat) { self.physicsBody?.friction = friction }
    func getFriction() -> CGFloat { return (self.physicsBody?.friction)! }
    
    func setVelocity(velocity: CGVector) { self.physicsBody?.velocity = velocity }
    func setVelocity(x: CGFloat, y: CGFloat) { self.physicsBody?.velocity = CGVectorMake(x, y) }
    func getVelocity() -> CGVector { return (self.physicsBody?.velocity)! }
    
    func setAngularVelocity(angVel: CGFloat) { self.physicsBody?.angularVelocity = angVel }
    func getAngularVelocity() -> CGFloat { return (self.physicsBody?.angularVelocity)! }
    
    
    // Returns the current acceleration of the object.
    func getAcceleration() -> CGVector {
        // Implement later using change of velocity
        return acceleration
    }
    
    func getForce() -> CGVector {
        return force
    }
    
    // Returns the kinetic energy of the object.
    func getKineticEnergy() -> CGFloat
    {
        let vel = (self.physicsBody?.velocity)!
        let v_squared = (vel.dx * vel.dx) + (vel.dy * vel.dy)
        return (1/2) * (self.physicsBody?.mass)! * (v_squared)
    }
    
    // Returns the momentum of the object.
    func getMomentum() -> CGVector
    {
        let vel = (self.physicsBody?.velocity)!
        let mass = (self.physicsBody?.mass)!
        let momentum = CGVector.init(dx: vel.dx * mass, dy: vel.dy * mass)
        
        return momentum
    }
    
    // Applies instantaneous acceleration to the object.
    // To make it continuous, have it call this function
    // every time step in the update function of GameScene.
    func applyAcceleration(x: CGFloat, y: CGFloat)
    {
        let mass = (self.physicsBody?.mass)!
        let accelerationVector = CGVector.init(dx: x * mass, dy: y * mass)
        self.physicsBody?.applyForce(accelerationVector);
        self.acceleration = accelerationVector
    }
    func applyAcceleration(magnitude: CGFloat, direction: CGFloat) // Polar form
    {
        let mass = (self.physicsBody?.mass)!
        let x = magnitude * cos(direction) * mass
        let y = magnitude * sin(direction) * mass
        let accelerationVector = CGVector.init(dx: x * mass, dy: y * mass)
        self.physicsBody?.applyForce(accelerationVector)
        self.acceleration = accelerationVector
    }
    
    // Applys an instaneous force to the object.
    func applyForce(x: CGFloat, y: CGFloat) // Cartesian Form
    {
        self.physicsBody?.applyForce(CGVector.init(dx: x, dy: y))
        self.force = CGVector.init(dx: x, dy: y)
    }
    
    func applyForce(magnitude: CGFloat, direction: CGFloat) // Polar form
    {
        let x = magnitude * cos(direction)
        let y = magnitude * sin(direction)
        let vec = CGVector(dx: x, dy: y)
        self.physicsBody?.applyForce(vec)
        self.force = vec
    }
    
    
    // ##############################################################
    //
    //  Descriptor functions:
    //  Functions that aid in finding information about other sprites
    //  relative to this one.
    //
    // ##############################################################
    
    // Finds the nonscaled distance between two sprite nodes. It is
    // nonscaled in the sense that it returns the absolute distance
    // in terms of pixels rather than the scaled metric.
    func distanceTo(sprite: PWObject) -> CGFloat {
        assert(PWObject.isPWObject(sprite));
        
        let n1 = self.position
        let n2 = sprite.position
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        
        return distance;
    }
    
    // Same as the other distanceTo except it returns it relative to the 
    // point specified.
    func distanceToPoint(point: CGPoint) -> CGFloat {
        let n1 = self.position
        let n2 = point
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        
        return distance;
    }
    
    // Returns the angle from this object to sprite relative to
    // the horizontal x axis.
    func angleTo(sprite: PWObject) -> CGFloat {
        let n1 = self.getPos();
        let n2 = sprite.getPos();
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        
        let angle = atan2f(Float(deltay), Float(deltax))
        return CGFloat(angle);
    }
    
    
    // ##############################################################
    //
    //  Creation functions:
    //  Functions that directly connect or in any way interact with another
    //  sprite through the physics body.
    //
    // ##############################################################
    
    /// Currently doesn't contain any functions.
    
    // ##############################################################
    //
    //  Aesthetic functions:
    //  Functions that change the visual effects of PWObjects.
    //  Basically anything that does not affect the physics and still
    //  performs visual/audio actions.
    //
    // ##############################################################
    
    // Highlights the node. Currently used when being selected.
    func highlight(color: UIColor) {
        self.unhighlight();
        let glow = SKShapeNode.init(rectOfSize: self.size)
        glow.position = CGPoint(x: 0, y: 0)
        glow.fillColor = color;
        glow.alpha = 0.5
        glow.blendMode = SKBlendMode.Subtract
        
        self.glowNode = glow
        self.addChild(glow);
    }
    
    // Unhighlights the node.
    func unhighlight() {
        if (glowNode == nil) { return }
        glowNode!.removeFromParent()
    }
    
    
    // ##############################################################
    
    // Initializes the sprite object. This is what we will use to create
    // PWObjects set at specific coordinates.
    required init(objectStringName: String, position: CGPoint, isMovable: Bool, isSelectable: Bool) {
        PWObject.initStaticVariables(); // Mandatory call to populate static variables.
        
        let objTextureName = PWObject.getObjectTextureName(objectStringName)
        assert(objTextureName != nil, "Error: Initialization of PWObject couldn't find the object passed.")
        
        self.objectStringName = objectStringName
        self.objectPosition = position
        self.movable = isMovable
        self.selectable = isSelectable
        
        let objectTexture = SKTexture.init(imageNamed: objTextureName!)
        let textureSize = objectTexture.size()
        let white = UIColor.init(white: 1.0, alpha: 1.0);
        self.acceleration = CGVector.init(dx: 0.0, dy: 0.0)
        self.force = CGVector.init(dx: 0.0, dy: 0.0)
        super.init(texture: objectTexture, color: white, size: textureSize)
        
        let size = CGSize(width: 40, height: 40)
        
        self.movable = isMovable
        self.selectable = isSelectable
        
        self.size = size
        self.position = position
        self.name = objectStringName
        self.physicsBody = SKPhysicsBody(texture: objectTexture, size: size)
        self.physicsBody?.mass = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0.7
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Sprites;
    }
    
    // Initialize object without texture, only color.
    // This will be used to create a floor.
    required convenience init(objName: String, position: CGPoint, color: UIColor, size: CGSize, isMovable: Bool, isSelectable: Bool)
    {
        PWObject.initStaticVariables(); // Mandatory call to populate static variables.
        
        self.init(objectStringName: objName, position: position, isMovable: isMovable, isSelectable: isSelectable)
        
        self.movable = isMovable
        self.selectable = isSelectable
        
        self.size = size
        self.position = position
        self.name = objName
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.mass = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0.7
        self.physicsBody?.dynamic = isMovable;
    }
    
    // Creates a floor for the physics simulation.
    static func createFloor(size: CGSize) -> PWObject {
        PWObject.initStaticVariables(); // Mandatory call to populate static variables.
        
        let floor = self.init(objName: "floor", position: CGPoint(x: size.width/2, y: 0), color: UIColor.blackColor(), size: size, isMovable: false, isSelectable: false);
        // We don't want the floor to announe when something hits it.
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.None;
        
        return floor;
    }
    
    // Checks if the Spritekit node is an PWObject. This works for any
    // subclass of SKNode (SkSpriteNode, SKShapeNode, etc.)
    static func isPWObject(node: SKNode) -> Bool {
        let pwObj = node as? PWObject
        
        if (pwObj == nil) { return false}
        return (pwObj!.isSprite());
    }
    
    // Saves data into hardware
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(objectStringName, forKey: "objectStringName")
        aCoder.encodeCGPoint(objectPosition, forKey: "objectPosition")
        aCoder.encodeBool(movable, forKey: "movable")
        aCoder.encodeBool(selectable, forKey: "selectable")
        aCoder.encodeCGVector(self.getVelocity(), forKey: "velocity")
        aCoder.encodeObject(self.getMass(), forKey: "objMass")
        aCoder.encodeObject(self.getAngularVelocity(), forKey: "angularVelocity")
        aCoder.encodeCGVector(self.getAcceleration(), forKey: "acceleration")
        aCoder.encodeCGVector(self.getForce(), forKey: "force")
    }
    
    // Obtains saved data from hardware
    required convenience init?(coder aDecoder: NSCoder) {
        let objectStringName = aDecoder.decodeObjectForKey("objectStringName") as! String
        let objectPosition = aDecoder.decodeCGPointForKey("objectPosition")
        let movable = aDecoder.decodeBoolForKey("movable")
        let selectable = aDecoder.decodeBoolForKey("selectable")
        let velocity = aDecoder.decodeCGVectorForKey("velocity")
        let objMass = aDecoder.decodeObjectForKey("objMass") as! CGFloat
        let angularVelocity = aDecoder.decodeObjectForKey("angularVelocity") as! CGFloat
        let acceleration = aDecoder.decodeCGVectorForKey("acceleration")
        let force = aDecoder.decodeCGVectorForKey("force")
        
        self.init(objectStringName: objectStringName, position: objectPosition, isMovable: movable, isSelectable: selectable)
        self.setVelocity(velocity);
        self.setMass(objMass)
        self.setAngularVelocity(angularVelocity/CGFloat(metricScale))
        self.applyAcceleration(acceleration.dx/CGFloat(metricScale), y: acceleration.dy/CGFloat(metricScale))
        self.applyForce(force.dx/CGFloat(metricScale), y: force.dy/CGFloat(metricScale))
    }
}