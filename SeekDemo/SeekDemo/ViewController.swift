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

class SeekDemoViewController: UIViewController, SCNSceneRendererDelegate{
    
    var scene: SCNScene!
    var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize scene:
        
        scene = SCNScene(named: "Tank")
        
        //Create a camera to view our scene:
        //Camera Node:
        let cameraNode = SCNNode()
        //Attach a camera to the node:
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 35)
        
        //Add camera node to the root node:
        scene.rootNode.addChildNode(cameraNode)
        
        //Initialize default view as a Scene View:
        sceneView = self.view as? SCNView
        //Set the view to our created scene:
        sceneView.scene = scene
        
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true
        
        // configure the view
        let backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        sceneView.backgroundColor = backgroundColor
        
        //Set sceneView as a delegate to SCNSceneRenderer to override the renderer function:
        sceneView.delegate = self as SCNSceneRendererDelegate
        //Continue updating frames:
        sceneView.isPlaying = true
        
    }


}

