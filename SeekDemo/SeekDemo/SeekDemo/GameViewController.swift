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

    var scene: SCNScene!
    var targetNode: SCNNode!
    var minnow: Minnow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/Aquarium.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 35)
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
        targetNode.position = SCNVector3Make(3.0, 2.0, -6.0)
        targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(targetNode)
        
        let fishGeo = SCNPyramid(width: 0.25, height: 0.25, length: 0.25)
        fishGeo.firstMaterial?.diffuse.contents = UIColor(displayP3Red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        let origin = SCNVector3Make(0.0, 5.0, 0.0)
        minnow = Minnow(origin: origin)
        minnow.geometry = fishGeo
        minnow.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        minnow.physicsBody?.isAffectedByGravity = false
        scene.rootNode.addChildNode(minnow)
        
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
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let force = minnow.seek(target: targetNode.position)
        //minnow.update()
        //Instantaneous application:
        minnow.physicsBody?.applyForce(force, asImpulse: true)
       Swift.print(force)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
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
