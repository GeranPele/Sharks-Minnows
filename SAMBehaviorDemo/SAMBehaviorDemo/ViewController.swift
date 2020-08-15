//
//  ViewController.swift
//  SAMBehaviorDemo
//
//  Created by Geran Pele on 8/6/20.
//  Copyright © 2020 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit
import simd

class ViewController: UIViewController, SCNSceneRendererDelegate {
    

    //Create a scene kit scene object
    let scene = SCNScene()
    var camera = SCNNode()
    var minnows: [Minnow] = []
    var shark: Shark!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEnvironment()
        //Create a scene view from the physical view bounds
        let sceneView = SCNView(frame: UIScreen.main.bounds)
        //Set scene view delegate to self so we can harness the rendering cycle
        sceneView.delegate = self
        //Set the scene view to display the scene kit scene we created
        sceneView.scene = scene
        //Play with the camera
        sceneView.allowsCameraControl = true
        //Set sceneview background to blue
        sceneView.backgroundColor = UIColor(ciColor: .blue)
        //Add the scene view to the device view hierarchy
        self.view.addSubview(sceneView)
        
        createMinnows()
        shark = Shark(origin: SCNVector3Make(0.0, 2.5, 0.0))
        scene.rootNode.addChildNode(shark)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        shark.update()
        
        for m in minnows{
            
            m.update()
            
            if(m.isWithinFleeDistance(Target: shark.presentation.position)){
              m.flee(Target: shark.presentation.position)
            }else if(!m.isWithinFleeDistance(Target: shark.presentation.position)){
              m.school(Minnows: minnows)
            }
            
            if(shark.isWithinChasingDistance(Target: m.presentation.position)){
                shark.seek(Target: m.presentation.position)
            }
        }
        
    }

    
    func loadEnvironment(){
        camera.camera = SCNCamera()
        camera.name = "Camera"
        camera.position = SCNVector3(x: 0, y: 5, z: 10)
        camera.look(at: SCNVector3Make(0, 0, 0))
        
        let spotLight = SCNNode()
        spotLight.name = "Spotlight"
        spotLight.light = SCNLight()
        spotLight.light!.type = .spot
        spotLight.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        spotLight.position = SCNVector3(x: 0, y: 50, z: 0)
        
        let floorGeo = SCNFloor()
        floorGeo.reflectionFalloffEnd = 0
        floorGeo.reflectivity = 0
        let floor = SCNNode(geometry: floorGeo)
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: .init(geometry: (floor.geometry)!, options: nil))
        floor.geometry?.materials.first?.diffuse.contents = UIColor(ciColor: .blue)
        scene.rootNode.addChildNode(floor)
        scene.rootNode.addChildNode(camera)
        //scene.rootNode.addChildNode(spotLight)
    }
    
    func createMinnows(){
        
        for x in 0...30{
            let minnow = Minnow(origin: SCNVector3Make(0, Float(x), 0))
            let minnow2 = Minnow(origin: SCNVector3Make(Float(x),0,0))
            let minnow3 = Minnow(origin: SCNVector3Make(Float(x),0,Float(x)))
            minnows.append(minnow)
            minnows.append(minnow2)
            minnows.append(minnow3)
            scene.rootNode.addChildNode(minnow)
        }
    }

}

