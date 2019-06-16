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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
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
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        //Set delegate to self:
        sceneView.delegate = self
        //Show obtained feature points for plane detection:
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWireframe, ARSCNDebugOptions.showPhysicsFields]
        
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
        
        for box in 0...50{
            let boxGeo = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.0)
            boxGeo.firstMaterial?.diffuse.contents = UIColor.red
            let boxNode = SCNNode(geometry: boxGeo)
            
            boxNode.position = SCNVector3(x, y + 0.1, z)
            
            boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            boxNode.physicsBody?.restitution = 0.1
            sceneView.scene.rootNode.addChildNode(boxNode)
        }
        
        /*
        guard let shipScene = SCNScene(named: "/art.scnassets/Tank.scn"),
            let shipNode = shipScene.rootNode.childNode(withName: "Brep", recursively: false)
            else {
                
                Swift.print("Oh no!")
                
                return
        }
        
        
        shipNode.position = SCNVector3(x,y,z)
        
        sceneView.scene.rootNode.addChildNode(shipNode)
         */
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addTankToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

