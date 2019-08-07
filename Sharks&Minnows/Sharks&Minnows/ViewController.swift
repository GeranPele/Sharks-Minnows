//
//  ViewController.swift
//  Sharks&Minnows
//
//  Created by Geran Pele on 7/28/19.
//  Copyright © 2019 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

//Orientation
//Sometimes collide through the walls (Make them thicker?)

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var testVector = SCNVector3(1.0, 0.0, 0.0)
    
    //Keep track of time in seconds since launch
    var timeSinceLaunch = 0.0
    //Observer method
    var dTime: Int = 0{
        
        didSet{
            timeSinceLaunch += 0.01
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToSceneView()
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

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, /*ARSCNDebugOptions.showWireframe,*/ ARSCNDebugOptions.showPhysicsFields, ARSCNDebugOptions.showPhysicsShapes]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        /*
        let look = SCNVector3Make(0.0, 0.0, 0.0)
        let up = SCNVector3Make(0.0, 1.0, 0.0)
        let front = SCNVector3Make(1.0, 0.0, 0.0)
        */
        for node in sceneView.scene.rootNode.childNodes{
            node.physicsBody?.applyForce(testVector, asImpulse: false)
           
            if (node.name == "Minnow"){
                //node.look(at: look, up: up, localFront: front)
            }
        }
        //Trickery to get time in seconds since launch:
        dTime = Int(time) % 2
        
        if(timeSinceLaunch > 3){
            testVector *= -1.0
            timeSinceLaunch = 0
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(generateARSurfacePlane(planeAnchor: planeAnchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updateARSurfacePlane(node: node, anchor: anchor)
    }
    
    
    @objc func addTankToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        
        let positionCenter = SCNVector3Make(translation.x, translation.y,  translation.z)
        //Make the tank
        let tank = Tank(position: positionCenter)
        //Make minnows
        for _ in 0...5{
            let minnow = Minnow(origin: SCNVector3Make(positionCenter.x, positionCenter.y + 0.5, positionCenter.z))
            //Add minnows to the tank
            tank.scene.rootNode.addChildNode(minnow)
        }
        //Add all nodes from tank to the scene
        for node in tank.scene.rootNode.childNodes{
           sceneView.scene.rootNode.addChildNode(node)
        }
        sceneView.scene.physicsWorld.gravity = tank.scene.physicsWorld.gravity
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addTankToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func generateARSurfacePlane(planeAnchor: ARPlaneAnchor) -> SCNNode{
 
        //Create plane geometry from our ARPlaneAnchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        //Transparent gray
        plane.materials.first?.diffuse.contents = UIColor.init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
        
        //Create a node for the plane using the geometry we created
        let planeNode = SCNNode(geometry: plane)
        //Center the plane on the anchor
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        //Aligns the x-axis?
        planeNode.eulerAngles.x = -.pi / 2
        
        return planeNode
    }
    
    func updateARSurfacePlane(node: SCNNode, anchor: ARAnchor){
        
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
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
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
