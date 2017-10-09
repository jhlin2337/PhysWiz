//
//  PWStaticObject.swift
//  Physics Wizard
//
//  Created by James Lin on 2/5/17.
//  Copyright © 2017 James Lin. All rights reserved.
//

import Foundation
import SpriteKit

class PWStaticObject: SKShapeNode {
    
    required init(objectName: String, objectPosition: CGPoint, objectSize: CGSize) {
        super.init()

        var polygonPath = CGMutablePath()
        // Defines the shape that will be created
        if (objectName == "rectangle") {
            polygonPath = createRectangle(objectSize: objectSize)
        } else if (objectName == "triangle") {
            polygonPath = createTriangle(objectSize: objectSize)
        } else if (objectName == "circle") {
            polygonPath = createCircle(objectSize: objectSize)
        } else {
            return
        }
        
        self.path = polygonPath
        self.strokeColor = SKColor.black
        self.fillColor = SKColor.black
        self.name = "staticObject"
        self.position = centerObjectPosition(objectPosition: objectPosition, objectSize: objectSize)
        
        self.physicsBody = SKPhysicsBody(polygonFrom: polygonPath)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Returns the CGPath of a rectangle
    private func createRectangle(objectSize: CGSize) -> CGMutablePath {
        let rectPath = CGMutablePath()
        rectPath.move(to: CGPoint(x: 0, y:0))
        rectPath.addLine(to: CGPoint(x: objectSize.width, y: 0))
        rectPath.addLine(to: CGPoint(x: objectSize.width, y: objectSize.height))
        rectPath.addLine(to: CGPoint(x: 0, y: objectSize.height))
        rectPath.addLine(to: CGPoint(x: 0, y: 0))
        return rectPath
    }
    
    // Returns the CGPath of a triangle
    private func createTriangle(objectSize: CGSize) -> CGMutablePath {
        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: 0, y: 0))
        trianglePath.addLine(to: CGPoint(x: objectSize.width, y:0))
        trianglePath.addLine(to: CGPoint(x: objectSize.width, y: objectSize.height))
        trianglePath.addLine(to: CGPoint(x: 0, y:0))
        return trianglePath
    }
    
    // Returns the CGPath of a circle
    private func createCircle(objectSize: CGSize) -> CGMutablePath {
        let circlePath = CGMutablePath()
        let ellipseRect = CGRect(x: 0, y: 0, width: objectSize.width, height: objectSize.height)
        circlePath.addEllipse(in: ellipseRect)
        return circlePath
    }
    
    private func centerObjectPosition(objectPosition: CGPoint, objectSize: CGSize) -> CGPoint {
        return CGPoint(x: objectPosition.x - objectSize.width/2, y: objectPosition.y - objectSize.height/2)
    }
}
