//
//  ViewController.swift
//  PhysicsBodyTesting
//
//  Created by Geran Pele on 6/16/19.
//  Copyright © 2019 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit
import GameplayKit
import QuartzCore

class ViewController: UIViewController, SCNSceneRendererDelegate {
    
    var scene: SCNScene!
    var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize scene:
        
        scene = SCNScene(named: "art.scnassets/Tank.scn")
        
        //Create a camera to view our scene:
        //Camera Node:
        let cameraNode = SCNNode()
        //Attach a camera to the node:
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        //Add camera node to the root node:
        scene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene:
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .spot
        lightNode.position = SCNVector3(x: 0, y: 15, z: 0)
        lightNode.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        scene.rootNode.addChildNode(lightNode)
        
        
        //Initialize default view as a Scene View:
        sceneView = (self.view as! SCNView)
        //Set the view to our created scene:
        sceneView.scene = scene
        let backgroundColor = UIColor.init(red: 0.0273, green: 0.0351, blue: 0.2382, alpha: 1.0)
        sceneView.backgroundColor = backgroundColor
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = false
        sceneView.debugOptions = [.showWireframe, .showBoundingBoxes, .showPhysicsFields, .showConstraints, .showPhysicsShapes]
        addTapGestureToSceneView()
        
        
        //Set sceneView delegate as self:
        sceneView.delegate = self //as SCNSceneRendererDelegate
        //Continue updating frames:
        sceneView.isPlaying = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    
    @objc func createBox(withGestureRecognizer recognizer: UIGestureRecognizer){
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: [SCNHitTestOption.boundingBoxOnly: true])
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.localCoordinates
        var x = translation.x
        var y = translation.y
        var z = translation.z
        
        for box in 0...50{
            let boxGeo = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
            boxGeo.firstMaterial?.diffuse.contents = UIColor.red
            let boxNode = SCNNode(geometry: boxGeo)
            
            y += Float(box/5)
            
            boxNode.position = SCNVector3(x, y, z)
            
            boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            //Can adopt more native style physics in re-implementation of physics system!
            boxNode.physicsBody!.restitution = 1.0
            boxNode.physicsBody!.damping = 0.4
            boxNode.physicsBody!.friction = 0.4
            
            scene.rootNode.addChildNode(boxNode)
        }
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.createBox(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
}
}
