//
//  Minnow.swift
//  SAMBehaviorDemo
//
//  Created by Geran Pele on 8/1/20.
//  Copyright © 2020 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit

class Minnow: SCNNode {
    
    var acceleration: SCNVector3
    var forwardVector = SCNVector3Make(0, 0, -1)
    var neighborDistance: Float = 1.0
    var separationDistance: Float = 0.25
    var maxSpeed: Float = 0.05
    var maxForce: Float = 0.05
    var fleeCount: Int = 0
    var wall: Float = 7.0
    var fishColor = UIColor()
    //Add mass later
    
    //Default constructor
    override init() {
        acceleration = SCNVector3Make(0, 0, 0)
        fishColor = UIColor(displayP3Red: CGFloat.random(in: 0..<1), green: CGFloat(Float.random(in: 0..<1)), blue: CGFloat(Float.random(in: 0..<1)), alpha: CGFloat.random(in: 0..<1))
        super.init()
        loadGeometry()
        self.position = SCNVector3Make(0, 0, 0)
    }
    
    //Preferred constructor
     init(origin: SCNVector3) {
        acceleration = SCNVector3Make(0, 0, 0)
        fishColor = UIColor(displayP3Red: CGFloat.random(in: 0..<1), green: CGFloat(Float.random(in: 0..<1)), blue: CGFloat(Float.random(in: 0..<1)), alpha: 1.0)
        super.init()
        loadGeometry()
        self.position = origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadGeometry(){
        //Grab the Fish scene file
        let fishScene = SCNScene(named: "art.scnassets/Fish.dae")
        //Take Geometry from the scene and apply it to the Minnow
        self.geometry = fishScene!.rootNode.childNode(withName: "Fish", recursively: true)?.geometry
        //Create a physics body from the geometry
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: .init(geometry: (self.geometry)!, options: nil))
        //Turn off affected by gravity
        self.physicsBody?.isAffectedByGravity = false
        //Need to initialize a starting velocity or nothing happens
        self.physicsBody?.velocity = SCNVector3(0.0,0.0,0.1)
        self.geometry?.materials.first?.diffuse.contents = fishColor
    }
    
    func update(){
        //Add acceleration to velocity
        self.physicsBody!.velocity += acceleration
        //Limit velocity by our max speed
        self.physicsBody!.velocity.limit(mag: maxSpeed)
        //Add velocity to position to create movement
        self.position += self.physicsBody!.velocity
        //Set acceleration to zero so it doesn't compound
        acceleration *= 0.0
        //Grab the unit vector of our current velocity
        var vn = self.physicsBody!.velocity
        vn.normalize()
        //Get the cross product between our current velocity and 'true forward'
        let crossProduct: SCNVector3 = forwardVector.cross(toVector: vn)
        //Calculate the appropriate rotation angle from the dot product between 'true forward' and our velocity
        let rotationAngle: Float = forwardVector.dot(toVector: vn)
        //Create a quaternion to set the rotation of the node
        self.rotation = SCNVector4Make(crossProduct.x, crossProduct.y, crossProduct.z, acos(rotationAngle))
        
        keepInBounds()
        
        if(fleeCount > 0){
            fleeCount -= 1
            self.geometry?.materials.first?.diffuse.contents = UIColor(ciColor: .red)
        }else{
            self.geometry?.materials.first?.diffuse.contents = fishColor
        }
    }
    
    func keepInBounds(){
        var rebound = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
          
          let Xmin: Float = -wall;
          let Ymin: Float = 0.0;
          let Zmin: Float = -wall;
          
          let Xmax: Float = wall;
          let Ymax: Float = wall;
          let Zmax: Float = wall;
          
        if(self.presentation.position.x < Xmin){
            rebound.x = 2;
          }
          
        if(self.presentation.position.x > Xmax){
            rebound.x = -2;
          }
          
        if(self.presentation.position.y < Ymin){
            rebound.y = 2;
          }
          
        if(self.presentation.position.y > Ymax){
            rebound.y = -2;
          }
          
        if(self.presentation.position.z < Zmin){
            rebound.z = 2;
          }
          
        if(self.presentation.position.z > Zmax){
            rebound.z = -2;
          }
          
          applyForce(Force: rebound)
        }
    
    func applyForce(Force: SCNVector3){
        //Add our forces to acceleration
        acceleration += Force
    }
    
    func seek(Target: SCNVector3) -> SCNVector3{
        //Create a desired vector by subtractig our position from the target position
        var desired = Target - self.presentation.position
        //Get unit vector of desired
        desired.normalize()
        //Multiply by our max speed
        desired *= maxSpeed
        //Create a steering vector by subtractingg our current velocity vector from the desired vector
        var steer = desired - self.physicsBody!.velocity
        //Limit by max force
        steer *= maxForce
        return steer
    }
    
    func flee(Target: SCNVector3){
        //Create an undesired vector by subtractig the target position from our position
        var undesired =  self.presentation.position - Target
        //Get unit vector of desired
        undesired.normalize()
        //Multiply by our max speed
        undesired *= maxSpeed
        //Maybe super charge this?
        //Create a steering vector by subtractingg our current velocity vector from the desired vector
        var steer = undesired - self.physicsBody!.velocity
        //Limit by max force
        steer *= maxForce
        applyForce(Force: steer)
    }
    
    func isWithinFleeDistance(Target: SCNVector3) -> Bool{
        let dist = self.presentation.position.distance(toVector: Target)
        if(dist <= 0.5){
            print("Chomp")
            self.removeFromParentNode()
        }
        if(dist <= 4.0){
            if(fleeCount == 0){
                fleeCount = 60
            }
            return true
        }else{
            return false
        }
    }
    
    func align(Neighbors: [Minnow]) -> SCNVector3{
        //Accumulation of velocity vectors
        var sum = SCNVector3Make(0.0, 0.0, 0.0)
        //Neighbor count
        var count: Float = 0.0
        
        //Loop through neighbors
        for m in Neighbors{
            
            //Grab the distance from current minnow to the neighbor
            let dist = self.presentation.position.distance(toVector: m.presentation.position)
            //If we are within range accumulate velocity vector
            if ((dist > 0) && (dist < neighborDistance)) {
              sum += m.physicsBody!.velocity
              count += 1;
            }
        }
        
        //If there are neighbors
        if(count > 0){
            //Weight the sum of vectors by the number of neighbors
            sum /= count
            //Grab unit vector
            sum.normalize()
            //Scale by max speed
            sum *= maxSpeed
            //Create a steering vector based on the accumulation of the neighbors velocities
            var steer = sum - self.physicsBody!.velocity
            //Scale by our max force
            steer.limit(mag: maxForce)
            //Return the new steering vector
            return steer
        }else{
            //If there aren't any neighbors, return an 'empty' vector
            return SCNVector3Make(0.0, 0.0, 0.0)
        }
    }
    
    func separate(Neighbors: [Minnow]) -> SCNVector3{
        
        //Accumulation of velocity vectors
        var sum = SCNVector3Make(0.0, 0.0, 0.0)
        //Neighbor count
        var count: Float = 0.0
        
        //Loop through neighbors
        for m in Neighbors{
            
            //Grab the distance from current minnow to the neighbor
            let dist = self.presentation.position.distance(toVector: m.presentation.position)
            
            //If we are within range accumulate velocity vector
            if ((dist > 0) && (dist < separationDistance)) {
                
              var difference = self.presentation.position - m.presentation.position
              difference.normalize()
              difference /= dist
              sum += difference
              count += 1;
            }
        }
        
        //If there are neighbors
        if(count > 0){
            //Weight the sum of vectors by the number of neighbors
            sum /= count
            //Grab unit vector
            sum.normalize()
            //Scale by max speed
            sum *= maxSpeed
            //Create a steering vector based on the accumulation of the neighbors velocities
            var steer = sum - self.physicsBody!.velocity
            //Scale by our max force
            steer.limit(mag: maxForce)
            //Return the new steering vector
            return steer
        }else{
            //If there aren't any neighbors, return an 'empty' vector
            return SCNVector3Make(0.0, 0.0, 0.0)
        }
    }
    
    func cohesion(Neighbors: [Minnow]) -> SCNVector3{
        //Accumulation of velocity vectors
        var sum = SCNVector3Make(0.0, 0.0, 0.0)
        //Neighbor count
        var count: Float = 0.0
        
        //Loop through neighbors
        for m in Neighbors{
            
            //Grab the distance from current minnow to the neighbor
            let dist = self.presentation.position.distance(toVector: m.presentation.position)
            
            //If we are within range accumulate velocity vector
            if ((dist > 0) && (dist < neighborDistance)) {
              sum += m.presentation.position
              count += 1;
            }
        }
        
        //If there are neighbors
        if(count > 0){
            sum /= count
            return seek(Target: sum)
        }else{
            //If there aren't any neighbors, return an 'empty' vector
            return SCNVector3Make(0.0, 0.0, 0.0)
        }
    }
    
    func school(Minnows: [Minnow]){
        //Create our schooling vectors
        var alignment = align(Neighbors: Minnows)
        var separation = separate(Neighbors: Minnows)
        var cohesive = cohesion(Neighbors: Minnows)
        
        //Weight them
        alignment *= 0.8
        separation *= 0.1
        cohesive *= 0.5
        
        //Apply them
        applyForce(Force: alignment)
        applyForce(Force: separation)
        applyForce(Force: cohesive)
    }
    
}
