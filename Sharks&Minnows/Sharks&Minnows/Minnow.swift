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
    var maxForce: Float
    
    init(origin: SCNVector3){
        leadingNode = SCNNode()
        leadingNode.position = origin
        
        acceleration = SCNVector3Make(0.0, 0.0, 0.0)
        maxSpeed = 0.1
        maxForce = 5.0
        
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
    
    func run(minnows: [Minnow]){
        
        flock(minnows: minnows)
        update()
    }
    
    func applyForce(force: SCNVector3){
        
        let f: SCNVector3 = force
        acceleration = acceleration + f
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
    
    //Returns a seek to target vector
    func seek(target: SCNVector3) -> SCNVector3{
        
        var desired = target - leadingNode.position
        
        //desired.normalize()
        desired = desired * maxSpeed
        
        var steer: SCNVector3 = desired - self.physicsBody!.velocity
        steer.limit(mag: maxForce)
        
        //Explicitly applying force here for testing purposes:
        applyForce(force: steer)
        return steer
    }
    
    //Returns a flee from target vector
    func flee(target: SCNVector3) -> SCNVector3{
        
        var desired = leadingNode.position - target
        desired = desired * maxSpeed
        
        var steer: SCNVector3 = desired - self.physicsBody!.velocity
        steer.limit(mag: maxForce)
        
        //Explicitly applying force here for testing purposes:
        applyForce(force: steer)
        return steer
    }
    
    func align (neighbors : [Minnow]) -> SCNVector3 {
        
        let neighbordist: Float = 50.0;
        var sum = SCNVector3Make(0.0, 0.0, 0.0)
        var count: Float = 0.0;
        
        for minnow in neighbors{
            
        let dist = self.presentation.position.distance(toVector: minnow.presentation.position)
            
        if ((dist > 0) && (dist < neighbordist)) {
          sum += minnow.physicsBody!.velocity
          count += 1;
        }
      }
      if (count > 0) {
        sum /= SCNVector3Make(count, count, count)

        // Implement Reynolds: Steering = Desired - Velocity
        sum.normalize();
        sum = sum * maxSpeed
        var steer = sum - self.physicsBody!.velocity
        steer.limit(mag: maxForce)
        
        return steer
      }
      else {
        return SCNVector3Make(0.0, 0.0, 0.0)
      }
    }
    
    func separate (neighbors: [Minnow] ) -> SCNVector3{
        
        let desiredSeparation: Float = 25.0
        var steer = SCNVector3Make(0.0, 0.0, 0.0)
        var count: Float = 0.0;
       // For every boid in the system, check if it's too close
       for minnow in neighbors {
        
         let dist = self.presentation.position.distance(toVector: minnow.presentation.position)
         // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
         if ( (dist > 0) && (dist < desiredSeparation)) {
           // Calculate vector pointing away from neighbor
           var difference = self.presentation.position - minnow.presentation.position
           
           difference.normalize()
           difference /= dist        // Weight by distance
           steer += difference
           count += 1;           // Keep track of how many
         }
       }
       // Average -- divide by how many
       if (count > 0) {
         steer /= count
       }

       // As long as the vector is greater than 0
       if (steer.magnitude > 0) {
         
         // Implement Reynolds: Steering = Desired - Velocity
         steer.normalize()
         steer *= maxSpeed
         steer -= self.physicsBody!.velocity
        steer.limit(mag: maxForce)
       }
       return steer;
     }
    
    func cohesion (neighbors: [Minnow]) -> SCNVector3{
        
      let neighborDist: Float = 50.0
      var sum = SCNVector3Make(0.0, 0.0, 0.0)
        var count: Float = 0.0
      for minnow in neighbors {
        
        let dist = self.presentation.position.distance(toVector: minnow.presentation.position)
        if ((dist > 0) && (dist < neighborDist)) {
            
          sum += minnow.presentation.position
          count += 1;
        }
      }
      if (count > 0) {
        sum /= count
        return seek(target: sum);  // Steer towards the position
      }
      else {
        return SCNVector3Make(0.0, 0.0, 0.0)
      }
    }
    
    // We accumulate a new acceleration each time based on three rules
    func  flock(minnows: [Minnow]) {
      var sep = separate(neighbors: minnows)  // Separation
      var ali = align(neighbors: minnows)     // Alignment
      var coh = cohesion(neighbors: minnows)  // Cohesion
      // Arbitrarily weight these forces
      sep *= 1.5
      ali *= 1.0
      coh *= 1.0
      // Add the force vectors to acceleration
      //applyForce(force: sep);
      //applyForce(force: ali);
      //applyForce(force: coh);
    }
}
