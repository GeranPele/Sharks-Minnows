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
//Need heads up display and menu for camera view
// - Clear all nodes and start over
// - Add/Subract Minnnows
// - Add/Subract Sharks
// - Dials for changing Shark/Minnow behavior
//Confirm/Cancel tank creation
// - Should require a minimum size

class SAMViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var testTarget: SCNNode!
    var testVector = SCNVector3(0.001, 0.0, 0.0)
    //Keep track of time in seconds since launch
    var timeSinceLaunch = 0.0
    var minnows: [Minnow] = []
    var baseWidth: CGFloat = 0.0
    var baseHeight: CGFloat = 0.0
    //Observer method
    var dTime: Int = 0{
        
        didSet{
            timeSinceLaunch += 0.01
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let testTargetGeo = SCNSphere(radius: 0.008)
        testTargetGeo.materials.first!.diffuse.contents = UIColor.red
        testTarget = SCNNode(geometry: testTargetGeo)
        //testTarget.physicsBody = SCNPhysicsBody(type: .dynamic, shape: .init(geometry: testTargetGeo, options: nil))
        //testTarget.physicsBody?.isAffectedByGravity = false
        
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //set horizontal plane detection:
        configuration.planeDetection = [.horizontal]
        // Run the view's session
        sceneView.session.run(configuration)
        //Set delegate to self:
        sceneView.delegate = self

        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWireframe, ARSCNDebugOptions.showPhysicsFields, ARSCNDebugOptions.showPhysicsShapes]
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do something with the new transform
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        testTarget.position += testVector
        //Trickery to get time in seconds since launch:
        dTime = Int(time) % 2
        
        if(timeSinceLaunch > 5){
            testVector *= -1.0
            timeSinceLaunch = 0
        }
        
        for(index, minnow) in minnows.enumerated(){
            //minnow.run(minnows: minnows)
            //minnow.update()
            minnow.seek(target: testTarget.presentation.position)
            minnow.update()
        }
    }
    
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
        createTank(origin: positionCenter, width: baseWidth, height: baseHeight)
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SAMViewController.addTankToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func generateARSurfacePlane(planeAnchor: ARPlaneAnchor) -> SCNNode{
 
        //Create plane geometry from our ARPlaneAnchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        baseWidth = width
        baseHeight = height
        let plane = SCNPlane(width: width, height: height)
        
        //Transparent grey
        plane.materials.first?.diffuse.contents = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        
        
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
        baseWidth = width
        baseHeight = height
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
    
    //Will need to create tank dynamically
    func createTank(origin: SCNVector3, width: CGFloat, height: CGFloat){
        
        //physics bodies
        //remove arplane
        let floorGeo = SCNBox(width: baseWidth, height: 0.01, length: baseHeight, chamferRadius: 0.025)
        floorGeo.materials.first?.diffuse.contents = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.8)
        var floor = SCNNode(geometry: floorGeo)
        floor.position = origin
        floor.position.y += 0.01
        sceneView.scene.rootNode.addChildNode(floor)
        
        let wallGeo1 = SCNBox(width: baseWidth, height: 0.01, length: baseHeight/2.0, chamferRadius: 0.025)
        wallGeo1.materials.first?.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
        var wall1 = SCNNode(geometry: wallGeo1)
        wall1.position = origin
        wall1.position.y += Float(0.01 + baseHeight/4.0)
        wall1.position.z += Float(baseHeight / 2.0)
        wall1.eulerAngles.x = -.pi / 2
        sceneView.scene.rootNode.addChildNode(wall1)
        
        let wallGeo2 = SCNBox(width: baseWidth, height: 0.01, length: baseHeight/2.0, chamferRadius: 0.025)
        wallGeo2.materials.first?.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
        var wall2 = SCNNode(geometry: wallGeo2)
        wall2.position = origin
        wall2.position.y += Float(0.01 + baseHeight/4.0)
        wall2.position.z -= Float(baseHeight / 2.0)
        wall2.eulerAngles.x = -.pi / 2
        sceneView.scene.rootNode.addChildNode(wall2)
        
        let wallGeo3 = SCNBox(width: baseWidth/2.0, height: 0.01, length: baseHeight, chamferRadius: 0.025)
        wallGeo3.materials.first?.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
        var wall3 = SCNNode(geometry: wallGeo3)
        wall3.position = origin
        wall3.position.y += Float(0.01 + baseWidth/4.0)
        wall3.position.x -= Float(baseWidth / 2.0)
        wall3.eulerAngles.z = -.pi / 2
        sceneView.scene.rootNode.addChildNode(wall3)
        
        let wallGeo4 = SCNBox(width: baseWidth/2.0, height: 0.01, length: baseHeight, chamferRadius: 0.025)
        wallGeo4.materials.first?.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
        var wall4 = SCNNode(geometry: wallGeo4)
        wall4.position = origin
        wall4.position.y += Float(0.01 + baseWidth/4.0)
        wall4.position.x += Float(baseWidth / 2.0)
        wall4.eulerAngles.z = -.pi / 2
        sceneView.scene.rootNode.addChildNode(wall4)
        
        
        /*
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
        for _ in 0...0{
            let minnow = Minnow(origin: SCNVector3Make(origin.x, origin.y + 0.5, origin.z))
            //Add minnows to the tank
            sceneView.scene.rootNode.addChildNode(minnow)
            minnows.append(minnow)
        }
        
        testTarget.position = SCNVector3Make(origin.x, origin.y + 0.25, origin.z)
        
        sceneView.scene.rootNode.addChildNode(testTarget)
        */
    }
}

extension float4x4 {
    var translation: SIMD3<Float> {
        let translation = self.columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}
