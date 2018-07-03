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
    
    //LimitDesired!!
    
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
        
        guard let pb = physicsBody else { return SCNVector3Make(0, 0, 0) }
        var steer: SCNVector3 = desired - pb.velocity
        
        desired.normalize()
        desired = desired * maxSpeed
        
        steer.limit(mag: maxForce)
        
        return steer
    }
    
    func align(boids: [Minnow]) -> SCNVector3{
        
        let neighborDistance: Float = 15.0
        
        var sum: SCNVector3 = SCNVector3Make(0.0, 0.0, 0.0)
        
        var count: Int = 0
        
        for minnow in boids {
            
            let d = position.distance(toVector: minnow.presentation.position)
            
            if((d > 0) && (d < neighborDistance)){
                sum = sum + minnow.presentation.position
                count += 1
            }
        }
        
        if(count > 0){
            sum = sum / Float(count)
            sum.normalize()
            sum = sum * maxSpeed
            
            guard let pb = physicsBody else { return SCNVector3Make(0, 0, 0) }
            var steer: SCNVector3 = sum - pb.velocity
            steer.limit(mag: maxForce)
            
            steer *= 1.5
            
            return steer
        }else{
            return SCNVector3Make(0.0, 0.0, 0.0)
        }
    }
    
    func flock(boids: [Minnow]){
        
        //var separate: SCNVector3 = self.separate(boids: boids)
        var align: SCNVector3 = self.align(boids: boids)
        //var cohesion: SCNVector3 = self.cohesion(boids: boids)
        
        //Weight behaviors:
        //separate = separate * 1.2
        align = align * 1.1
        //cohesion = cohesion * 1.0
        
        //applyForce(force: separate)
        //applyForce(force: align)
        //applyForce(force: cohesion)
    }
    
    func heading() -> SCNVector3{
        guard let pb = physicsBody else { return SCNVector3Make(0.0, 0.0, 0.0)}
        let at = SCNVector3Make(presentation.position.x + pb.velocity.x, presentation.position.y + pb.velocity.y, presentation.position.z + pb.velocity.z)
        return at
    }
}



