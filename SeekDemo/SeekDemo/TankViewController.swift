//
//  ViewController.swift
//  SeekDemo
//
//  Created by Geran Pele on 2/12/19.
//  Copyright © 2019 Geran Pele. All rights reserved.
//
//First demonstration of 3D autonomous movement in SceneKit.  Seek a target and provide some obstacles to illustrate SceneKit's native abilities and what needs modification / improvment.


import UIKit
import SceneKit
import GameplayKit
import QuartzCore

class TankViewController: UIViewController, SCNSceneRendererDelegate{
    
    var scene: SCNScene!
    var sceneView: SCNView!
    var r,g,b: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        r = 0.0
        g = 0.0
        b = 0.0
        
        //Initialize scene:
        
        scene = SCNScene(named: "art.scnassets/Tank.scn")
        
        //Create a camera to view our scene:
        //Camera Node:
        let cameraNode = SCNNode()
        //Attach a camera to the node:
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        //Add camera node to the root node:
        scene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene:
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .spot
        lightNode.position = SCNVector3(x: 0, y: 5, z: 0)
        lightNode.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        scene.rootNode.addChildNode(lightNode)
        
        /*
        let moveUp = SCNAction.moveBy(x: 0, y: 0.1, z: 0, duration: 1)
        moveUp.timingMode = .easeInEaseOut;
        let moveDown = SCNAction.moveBy(x: 0, y: -0.1, z: 0, duration: 1)
        moveDown.timingMode = .easeInEaseOut;
        let moveSequence = SCNAction.sequence([moveUp,moveDown])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        
        for node in scene.rootNode.childNodes{
            if node.name == "Brep"{
                node.runAction(moveLoop)
            }
        }
        */
        
        //createBox()
        
        //Initialize default view as a Scene View:
        sceneView = self.view as! SCNView
        //Set the view to our created scene:
        sceneView.scene = scene
        
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = false
        sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showPhysicsFields, .showConstraints]
        
        // configure the view
        let backgroundColor = UIColor.init(red: 0.0273, green: 0.0351, blue: 0.2382, alpha: 1.0)
        sceneView.backgroundColor = backgroundColor
        
        //Set sceneView as a delegate to SCNSceneRenderer to override the renderer function:
        sceneView.delegate = self as SCNSceneRendererDelegate
        //Continue updating frames:
        sceneView.isPlaying = true
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

    }
    
}



