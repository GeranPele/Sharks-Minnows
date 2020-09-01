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

//Will dynamically create tab view controller


class SAMViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    //Keep track of time in seconds since launch
    var timeSinceLaunch = 0.0
    //var minnows: [Minnow] = []
    //Observer method
    var dTime: Int = 0{
        
        didSet{
            timeSinceLaunch += 0.01
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        //createTank(origin: positionCenter, width: baseWidth, height: baseHeight)
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SAMViewController.addTankToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func generateARSurfacePlane(planeAnchor: ARPlaneAnchor) -> SCNNode{
 
        //Create plane geometry from our ARPlaneAnchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        //baseWidth = width
        //baseHeight = height
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
        
        
    }

}

extension float4x4 {
    var translation: SIMD3<Float> {
        let translation = self.columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}
