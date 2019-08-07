//
//  Tank.swift
//  Sharks&Minnows
//
//  Created by Geran Pele on 7/28/19.
//  Copyright © 2019 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit

class Tank: SCNScene {
    
    var scene: SCNScene
    
    override init() {
        scene = SCNScene(named: "art.scnassets/Tank.scn")!
        super.init()
    }
    
    init(position: SCNVector3) {
        scene = SCNScene(named: "art.scnassets/Tank.scn")!
        super.init()
        updateLocalPosition(globalPosition: position)
        generateLighting(position: position)
        generatePhysicsEnvironment()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLocalPosition(globalPosition: SCNVector3){
        for node in scene.rootNode.childNodes{
            node.position = globalPosition
        }
    }
    
    func generateLighting(position: SCNVector3){
        
        // create and add a light to the scene:
        let spotLight = SCNNode()
        spotLight.light = SCNLight()
        spotLight.light!.type = .spot
        spotLight.position = SCNVector3(x: position.x, y: position.y + 15, z: position.z)
        spotLight.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        scene.rootNode.addChildNode(spotLight)
    }
    
    //Could make other functions like drag etc.
    func generatePhysicsEnvironment(){
        scene.physicsWorld.gravity = SCNVector3Make(0.0, -1.0, 0.0)
    }
}
