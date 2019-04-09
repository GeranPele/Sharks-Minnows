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
    //Orientation:
    var minnowLookAt: SCNNode!
    
    var rollV: GKRandomDistribution
    
    init(origin: SCNVector3){
        
        rollV = GKRandomDistribution(lowestValue: -2, highestValue: 2)
        location = SCNVector3Make(origin.x, origin.y, origin.z)
        velocity = SCNVector3Make(rollV.nextUniform(), rollV.nextUniform(), rollV.nextUniform())
        acceleration = SCNVector3Make(0.0, 0.0, 0.0)
        mass = 1.0
        maxSpeed = mass
        maxForce = mass / 20.0
        //Orientation:
        minnowLookAt = SCNNode()
        minnowLookAt.position = SCNVector3Make(0, 1, 0)
        let lac = SCNLookAtConstraint(target: minnowLookAt)
        lac.localFront = SCNVector3Make(0, 1, 0)
        super.init()
        position = origin
        self.constraints = [lac]
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
        //Orientation:
        guard let pb = physicsBody else { return }
        let worldLookAt = presentation.position + pb.velocity
        minnowLookAt.position = worldLookAt
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
    
    func flee(target: SCNVector3) -> SCNVector3{
        
        var desired = presentation.position - target
        
        //Work on limit desired function:
        //desired = limitDesired(target: desired, d: desired.magnitude)
        
        desired.normalize()
        desired = desired * maxSpeed
        
        var steer: SCNVector3 = desired - velocity
        steer.limit(mag: maxForce)
        
        return steer
    }
    
    func heading() -> SCNVector3{
        guard let pb = physicsBody else { return SCNVector3Make(0.0, 0.0, 0.0)}
        let at = SCNVector3Make(presentation.position.x + pb.velocity.x, presentation.position.y + pb.velocity.y, presentation.position.z + pb.velocity.z)
        return at
    }
}

