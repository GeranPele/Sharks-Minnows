//
//  Shark.swift
//  SAMBehaviorDemo
//
//  Created by Geran Pele on 8/12/20.
//  Copyright © 2020 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit

class Shark: SCNNode {
    
    var acceleration: SCNVector3
    var forwardVector = SCNVector3Make(0, 0, -1)
    var neighborDistance: Float = 1.0
    var separationDistance: Float = 0.25
    var maxSpeed: Float = 0.1
    var maxForce: Float = 0.005
    var wall: Float = 7.0
    //Add mass later
    
    //Default constructor
    override init() {
        acceleration = SCNVector3Make(0, 0, 0)
        
        super.init()
        loadGeometry()
        self.position = SCNVector3Make(0, 0, 0)
    }
    
    //Preferred constructor
     init(origin: SCNVector3) {
        acceleration = SCNVector3Make(0, 0, 0)
        
        super.init()
        loadGeometry()
        self.position = origin
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadGeometry(){
        //Grab the Shark scene file
        let sharkScene = SCNScene(named: "art.scnassets/Shark.dae")
        //Take Geometry from the scene and apply it to the Minnow
        self.geometry = sharkScene!.rootNode.childNode(withName: "Shark", recursively: true)?.geometry
        //Create a physics body from the geometry
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: .init(geometry: (self.geometry)!, options: nil))
        //Turn off affected by gravity
        self.physicsBody?.isAffectedByGravity = false
        //Need to initialize a starting velocity or nothing happens
        self.physicsBody?.velocity = SCNVector3(0.0,0.0,0.1)
        self.geometry?.materials.first?.diffuse.contents = UIColor(ciColor: .red)
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
    
    func seek(Target: SCNVector3){
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
        applyForce(Force: steer)
    }
    
    func isWithinChasingDistance(Target: SCNVector3) -> Bool{
        let dist = self.presentation.position.distance(toVector: Target)
        
        if(dist <= 4.0){
            return true
        }else{
            return false
        }
    }
}
