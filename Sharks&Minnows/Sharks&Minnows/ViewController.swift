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
//Sometimes collide through the walls work on collisions (margin, threshold)

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var testVector = SCNVector3(2.0, 0.0, 0.0)
    //Keep track of time in seconds since launch
    var timeSinceLaunch = 0.0
    var minnows: [Minnow] = []
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

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, /*ARSCNDebugOptions.showWireframe, ARSCNDebugOptions.showPhysicsFields, ARSCNDebugOptions.showPhysicsShapes*/]
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
        //let currentTransform = frame.camera.transform
        //var translation = matrix_identity_float4x4
        //translation.columns.3.z = -0.1 // Translate 10 cm in front of the camera
        //look.simdTransform = matrix_multiply(frame.camera.transform, translation)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //Trickery to get time in seconds since launch:
        dTime = Int(time) % 2
        
        if(timeSinceLaunch > 3){
            testVector *= -1.0
            timeSinceLaunch = 0
        }
        
        for minnow in minnows{
            minnow.run(minnows: minnows)
        }
    }

    //Converts the node's local forard into the world coordinate space
    //let localForwardVector = SCNVector3Make(0.0, 0.0, -0.1)
    //let worldForwardVector = node.presentation.convertVector(localForwardVector, to: nil)
    //leader.position = worldForwardVector
    //node.physicsBody?.velocity = worldForwardVector//better for testing at the least
    //node.physicsBody?.applyForce(worldForwardVector, asImpulse: false)//Not sure which way to implement this
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(generateARSurfacePlane(planeAnchor: planeAnchor))
    }
    
    //Need to work on this
    //Should just make one plane, then stop updating that plane and defining more feature points
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
        createTank(origin: positionCenter)
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
        //
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
    
    func createTank(origin: SCNVector3){
        let geometryScene = SCNScene(named: "art.scnassets/Tank.scn")!
        
        for node in geometryScene.rootNode.childNodes{
            node.position = origin
            sceneView.scene.rootNode.addChildNode(node)
        }
        
        // create and add a light to the Tank:
        let spotLight = SCNNode()
        spotLight.name = "SpotLight"
        spotLight.light = SCNLight()
        spotLight.light!.type = .spot
        spotLight.position = SCNVector3(x: origin.x, y: origin.y + 15, z: origin.z)
        spotLight.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
        sceneView.scene.rootNode.addChildNode(spotLight)
        
        //Gravity
        sceneView.scene.physicsWorld.gravity = SCNVector3Make(0.0, -1.0, 0.0)
        
        //Minnows
        for _ in 0...2{
            let minnow = Minnow(origin: SCNVector3Make(origin.x, origin.y + 0.5, origin.z))
            //Add minnows to the tank
            sceneView.scene.rootNode.addChildNode(minnow)
            minnows.append(minnow)
        }
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
