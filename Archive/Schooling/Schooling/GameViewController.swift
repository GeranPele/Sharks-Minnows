//
//  GameViewController.swift
//  SeekDemo
//
//  Created by Geran Pele on 6/11/18.
//  Copyright © 2018 Geran Pele. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    //Array of minnows!!
    var minnows: [Minnow] = []
    var scene: SCNScene!
    var targetNode: SCNNode!
    var sharkNode: SCNNode!
    var viewX: Float = 0.0
    var viewY: Float = 0.0
    var viewZ: Float = 0.0
    var cameraNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/Aquarium.scn")!
        
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 30, z: 10)
        cameraNode.look(at: SCNVector3Make(viewX, viewY, viewZ))
        scene.rootNode.addChildNode(cameraNode)
        
        
        // create and add a light to the scene:
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .spot
        lightNode.position = SCNVector3(x: 0, y: 50, z: 0)
        lightNode.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene:
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let targetGeo = SCNSphere(radius: 0.5)
        targetGeo.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0.0, green: 0.8, blue: 0.0, alpha: 0.8)
        targetNode = SCNNode(geometry: targetGeo)
        targetNode.position = SCNVector3Make(3.0, 2.5, -4.5)
        targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(targetNode)
        
        /*
        let sharkGeo = SCNSphere(radius: 0.8)
        sharkGeo.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0.7, green: 0.2, blue: 0.2, alpha: 0.8)
        sharkNode = SCNNode(geometry: sharkGeo)
        sharkNode.position = SCNVector3Make(0.0, 5.0, -5.0)
        sharkNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(sharkNode)
        */
        
        for _ in 1...10{
        let fishGeo = SCNPyramid(width: 0.25, height: 0.25, length: 0.25)
        fishGeo.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        let origin = SCNVector3Make(0.0, 1.0, 0.0)
        let minnow = Minnow(origin: origin)
        minnow.geometry = fishGeo
        minnow.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        minnow.physicsBody?.isAffectedByGravity = false
        minnows.append(minnow)
        scene.rootNode.addChildNode(minnow)
        }
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // configure the view
        let backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        scnView.backgroundColor = backgroundColor
        
        //Set sceneView as a delegate to SCNSceneRenderer to override the renderer function:
        scnView.delegate = self as SCNSceneRendererDelegate
        //Continue updating frames:
        scnView.isPlaying = true
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        for m in minnows{

        //One way to implement all forces:
        //Forces:
        let seekForce = m.seek(target: targetNode.position)
        var alignForce = m.align(boids: minnows)
        var cohesionForce = m.cohesion(boids: minnows)
        var separationForce = m.separate(boids: minnows)
            
        let summation = alignForce + separationForce + cohesionForce
        m.physicsBody?.applyForce(summation, asImpulse: true)
        m.update()
            Swift.print("this is a line of code")
        }
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}


