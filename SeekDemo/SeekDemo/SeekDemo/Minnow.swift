//
//  Minnow.swift
//  Sharks&Minnows2.0
//
//  Created by Geran Pele on 5/25/18.
//  Copyright © 2018 Geran Pele. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

class Minnow: SCNNode{
    
    var location: SCNVector3
    var mass: Float
    var maxSpeed: Float
    var maxForce: Float
    var velocity: SCNVector3
    var acceleration: SCNVector3
    
    var rollV: GKRandomDistribution
    
    init(origin: SCNVector3){
        
        rollV = GKRandomDistribution(lowestValue: -2, highestValue: 2)
        location = SCNVector3Make(origin.x, origin.y, origin.z)
        velocity = SCNVector3Make(rollV.nextUniform(), rollV.nextUniform(), rollV.nextUniform())
        acceleration = SCNVector3Make(0.0, 0.0, 0.0)
        mass = 1.0
        maxSpeed = mass
        maxForce = mass / 20.0
        super.init()
        position = origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Use native 'applyForce' function!
    func applyForce(force: SCNVector3){
        
        let f: SCNVector3 = force / mass
        acceleration = acceleration + f
    }
    
    func update(){
        
        guard let pb = physicsBody else { return }
        pb.velocity = pb.velocity + acceleration
        pb.velocity.limit(mag: maxSpeed)
        
        /************************************/
        //Not interchangable
        //location = location + velocity
        //position = position + velocity
        /************************************/
        acceleration = acceleration * 0.0
    }
    
    func seek(target: SCNVector3) -> SCNVector3{
        
        //Presentation node!
        //Utlilize look at constraints
        
        var desired = target - presentation.position
        
        desired.normalize()
        desired = desired * maxSpeed
        
        guard let pb = physicsBody else { return SCNVector3Make(0, 0, 0) }
        var steer: SCNVector3 = desired - pb.velocity
        steer.limit(mag: maxForce)
        
        return steer
    }
    
    func heading() -> SCNVector3{
        guard let pb = physicsBody else { return SCNVector3Make(0.0, 0.0, 0.0)}
        let at = SCNVector3Make(presentation.position.x + pb.velocity.x, presentation.position.y + pb.velocity.y, presentation.position.z + pb.velocity.z)
        return at
    }
}

