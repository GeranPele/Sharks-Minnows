//
//  Minnow.swift
//  Sharks&Minnows
//
//  Created by Geran Pele on 7/28/19.
//  Copyright © 2019 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit

//Tackle orientation
//Node is backwards, export it the other way maybe?
class Minnow: SCNNode {
    
    //Orientation Vector node.presentation.simdPosition + node.presentation.simdWorldFront
    var leadingNode: SCNNode
    var acceleration: SCNVector3
    var maxSpeed: Float
    init(origin: SCNVector3){
        leadingNode = SCNNode()
        leadingNode.position = origin
        
        acceleration = SCNVector3Make(0.0, 0.0, 0.0)
        maxSpeed = 1.0
        super.init()
        
        self.position = origin
        loadGeometry()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadGeometry(){
        let geometryScene = SCNScene(named: "art.scnassets/Minnow.scn")
        for node in (geometryScene?.rootNode.childNodes)!{
            if (node.name == "Minnow"){
                self.geometry = node.geometry
                let box = SCNBox(width: 0.01, height: 0.034, length: 0.043, chamferRadius: 0.0)
                let boundingBox = SCNPhysicsShape(geometry: box, options: nil)
                
                self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: boundingBox)
                physicsBody?.isAffectedByGravity = false
                //physicsBody?.continuousCollisionDetectionThreshold = 0.5 ???
                self.name = node.name
            }
        }
        
        let sphere = SCNSphere(radius: 0.01)
        leadingNode.geometry = sphere
        //leadingNode.position = SCNVector3Make(0.0, 0.0, 0.0)
        leadingNode.name = "leadingNode"
        //self.addChildNode(leadingNode)
        
        let leadingConstraints = SCNLookAtConstraint(target: leadingNode)
        //let upConstraints = SCNLookAtConstraint( Can we create an 'upConstraint' to keep the minnow from rolling
        self.constraints = [leadingConstraints]
    }
    
    func update(){
        
        //Update velocity:
        self.physicsBody!.velocity = self.physicsBody!.velocity + acceleration
        //Cap the velocity:
        self.physicsBody!.velocity.limit(mag: maxSpeed)
        //Set leading node's position:
        leadingNode.position = self.presentation.position + self.physicsBody!.velocity
        //Reset acceleraion:
        acceleration = acceleration * 0.0
    }
    
}
