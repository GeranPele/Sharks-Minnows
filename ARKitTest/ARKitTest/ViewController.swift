//
//  ViewController.swift
//  ARKitTest
//
//  Created by Geran Pele on 6/2/19.
//  Copyright © 2019 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import GameplayKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var rollX = GKRandomDistribution(lowestValue: -5, highestValue: 5)
    var rollZ = GKRandomDistribution(lowestValue: -5, highestValue: 5)
    
    
    var testVector = SCNVector3(1.0, 0.0, 0.0)
    var timeSinceLaunch = 0.0
    var dTime: Int?{
        
        didSet{
            timeSinceLaunch += 0.01
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sceneView.autoenablesDefaultLighting = true
        //sceneView.automaticallyUpdatesLighting = true
        addTapGestureToSceneView()
       
        /*
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Tank.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //set horizontal plane detection:
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        sceneView.session.run(configuration)
        //Set delegate to self:
        sceneView.delegate = self
        //!! Interesting !!//
        //Explicitly set gravity to mitigate jittery object placement:
        //sceneView.scene.physicsWorld.gravity = SCNVector3Make(0.0, -1.0, 0.0)
        //Show obtained feature points for plane detection:
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, /*ARSCNDebugOptions.showWireframe,*/ ARSCNDebugOptions.showPhysicsFields /*, ARSCNDebugOptions.showPhysicsShapes*/]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    // 1
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    // 2
    let width = CGFloat(planeAnchor.extent.x)
    let height = CGFloat(planeAnchor.extent.z)
    let plane = SCNPlane(width: width, height: height)
    
    // 3
    plane.materials.first?.diffuse.contents = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
    
    // 4
    let planeNode = SCNNode(geometry: plane)
    
    // 5
    let x = CGFloat(planeAnchor.center.x)
    let y = CGFloat(planeAnchor.center.y)
    let z = CGFloat(planeAnchor.center.z)
    planeNode.position = SCNVector3(x,y,z)
    
    //Rotate the plane?
    planeNode.eulerAngles.x = -.pi / 2
    
    // 6
    node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //1
    guard let planeAnchor = anchor as?  ARPlaneAnchor,
        let planeNode = node.childNodes.first,
        let plane = planeNode.geometry as? SCNPlane
        else { return }
    
    // 2
    let width = CGFloat(planeAnchor.extent.x)
    let height = CGFloat(planeAnchor.extent.z)
    plane.width = width
    plane.height = height
    
    // 3
    let x = CGFloat(planeAnchor.center.x)
    let y = CGFloat(planeAnchor.center.y)
    let z = CGFloat(planeAnchor.center.z)
    planeNode.position = SCNVector3(x, y, z)
    planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    planeNode.physicsBody?.isAffectedByGravity = false
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        for node in sceneView.scene.rootNode.childNodes{
            node.physicsBody?.applyForce(testVector, asImpulse: false)
        }
        //Trickery to get time in seconds since launch:
        dTime = Int(time) % 2
        
        if(timeSinceLaunch > 3){
            testVector *= -1.0
            timeSinceLaunch = 0
            
            print(testVector)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @objc func addTankToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        guard let tankScene = SCNScene(named: "/art.scnassets/TankScaled.scn"),
            let tankNode = tankScene.rootNode.childNode(withName: "Walls", recursively: false)
            else {
                Swift.print(Error.self)
                
                return
        }
        
        tankNode.position = SCNVector3(x,y,z)
        //Try logging collision detections!!
        sceneView.scene.rootNode.addChildNode(tankNode)
        for _ in 0...5{
            makeBoxes(x: x, y: y + 0.05, z: z)
        }
    
        // create and add a light to the scene:
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .spot
        lightNode.position = SCNVector3(x: x, y: y + 15, z: z)
        lightNode.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        sceneView.scene.physicsWorld.gravity = SCNVector3Make(0.0, -1.0, 0.0)
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addTankToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func makeBoxes(x: Float, y: Float, z: Float){
        //Objects scaled in meter:
        let boxGeo = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.0)
        boxGeo.firstMaterial?.diffuse.contents = UIColor.purple
        let boxNode = SCNNode(geometry: boxGeo)
        
        boxNode.position = SCNVector3(x, y, z)
        
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //Can adopt more native style physics in re-implementation of physics system!
        boxNode.physicsBody!.restitution = 1.0
        boxNode.physicsBody!.damping = 0.2
        boxNode.physicsBody!.friction = 0.4
        
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
