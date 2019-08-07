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
class Minnow: SCNNode {
    
    //var location: SCNVector3
    
    init(origin: SCNVector3){
        super.init()
        position = origin
        loadGeometry()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadGeometry(){
        let geometryScene = SCNScene(named: "art.scnassets/Minnow.scn")
        for node in (geometryScene?.rootNode.childNodes)!{
            if (node.name == "Minnow"){
                geometry = node.geometry
                let box = SCNBox(width: 0.01, height: 0.034, length: 0.043, chamferRadius: 0.0)
                let boundingBox = SCNPhysicsShape(geometry: box, options: nil)
                
                physicsBody = SCNPhysicsBody(type: .dynamic, shape: boundingBox)
                
                name = node.name
            }
        }
    }
}
