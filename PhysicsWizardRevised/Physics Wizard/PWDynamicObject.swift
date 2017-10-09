//
//  PWObject.swift
//  Physics Wizard
//
//  Created by James Lin on 2/1/17.
//  Copyright © 2017 James Lin. All rights reserved.
//

import Foundation
import SpriteKit

class PWDynamicObject: SKSpriteNode {
    
    //private var objectTextureName: String
    
    required init(objectTexture: SKTexture, objectPosition: CGPoint, objectSize: CGSize) {
        super.init(texture: objectTexture, color: UIColor.clear, size: objectSize)
        
        self.position = objectPosition
        self.name = "dynamicObject"
        
        self.physicsBody = SKPhysicsBody(texture: objectTexture, size: objectSize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.restitution = 0.7
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
