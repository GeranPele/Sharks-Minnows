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
    
    var rollX = GKRandomDistribution(lowestValue: -50, highestValue: 50)
    var rollZ = GKRandomDistribution(lowestValue: -50, highestValue: 50)
    
    var testForceVector = SCNVector3(x: 10.0, y: 0.0, z: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Initialize scene:
        
        scene = SCNScene(named: "art.scnassets/Tank.scn")
        
        //scene.physicsWorld.gravity = SCNVector3Make(0.0, -1.0, 0.0)

        //Create a camera to view our scene:
        //Camera Node:
        let cameraNode = SCNNode()
        //Attach a camera to the node:
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 300)
        
        //Add camera node to the root node:
        scene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene:
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .spot
        lightNode.position = SCNVector3(x: 0, y: 100, z: 0)
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

        //Initialize default view as a Scene View:
        sceneView = self.view as! SCNView
        //Set the view to our created scene:
        sceneView.scene = scene
        
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = false
        sceneView.debugOptions = [/*.showWireframe, .showBoundingBoxes, */.showPhysicsFields, .showConstraints, .showPhysicsShapes]
        
        // configure the view
        let backgroundColor = UIColor.init(red: 0.0273, green: 0.0351, blue: 0.2382, alpha: 1.0)
        sceneView.backgroundColor = backgroundColor
        
        //Set sceneView as a delegate to SCNSceneRenderer to override the renderer function:
        sceneView.delegate = self as SCNSceneRendererDelegate
        //Continue updating frames:
        sceneView.isPlaying = true
        
        addTapGestureToSceneView()
    }
    
    
    func createBox(x: Float, y: Float, z: Float){
        
        let boxGeo = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.0)
        boxGeo.firstMaterial?.diffuse.contents = UIColor.purple
        let boxNode = SCNNode(geometry: boxGeo)
        
        boxNode.position = SCNVector3(x, y, z)
        
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //Can adopt more native style physics in re-implementation of physics system!
        boxNode.physicsBody!.restitution = 1.0
       // boxNode.physicsBody!.damping = 0.4
        boxNode.physicsBody!.friction = 0.4
        scene.rootNode.addChildNode(boxNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        for node in scene.rootNode.childNodes{
            node.physicsBody?.applyForce(testForceVector, asImpulse: false)
        }
    }
    
    @objc func createBox(withGestureRecognizer recognizer: UIGestureRecognizer){
        for _ in 0...50{
            createBox(x: Float(rollX.nextInt()), y: 50.0, z: Float(rollZ.nextInt()))
        }
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TankViewController.createBox(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
