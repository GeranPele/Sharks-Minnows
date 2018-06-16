//
//  Pebble.swift
//  Sharks&Minnows2.0
//
//  Created by Geran Pele on 6/4/18.
//  Copyright © 2018 Geran Pele. All rights reserved.
//

import Foundation
import GameplayKit
import QuartzCore
import SceneKit
import UIKit


class Pebble: SCNNode{
        
    var location: SCNVector3
    var width: CGFloat
    var height: CGFloat
    var length: CGFloat
    var chamferRadius: Double
    var color: UIColor
    
        init(location: SCNVector3){
            
        self.location = SCNVector3Make(0.0, 10.0, 0.0)
        width = CGFloat(drand48())
        height = CGFloat(drand48())
        length = CGFloat(drand48())
        chamferRadius = 0.0625
        color = UIColor(displayP3Red: 0.3647, green: 0.5961, blue: 0.8667, alpha: 1.0)
            
        super.init()
        //position = self.location
        self.geometry = SCNBox(width: CGFloat(width), height: CGFloat(height), length: CGFloat(length), chamferRadius: CGFloat(chamferRadius))
        self.geometry?.firstMaterial?.diffuse.contents = color
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    }
    
    func update(){
        location = position
        /*
        location = location
        position = position
         */
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
