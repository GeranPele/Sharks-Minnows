//
//  ViewController.swift
//  AREnvironmentDemo
//
//  Created by Geran Pele on 8/6/20.
//  Copyright © 2020 Geran Pele. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    let arSceneView = ARSCNView(frame: UIScreen.main.bounds)
    var hud = SCNView(frame: UIScreen.main.bounds)
    var scene = SCNScene()
    var rotateZ: Float = 0.0
    var rotateX: Float = 0.0
    var rotateY: Float = 0.0
    var labelX = UILabel()
    var labelY = UILabel()
    var labelZ = UILabel()
    var sliderX = UISlider()
    var sliderY = UISlider()
    var sliderZ = UISlider()
    var addMinnowButton = UIButton()
    var settingsButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(arSceneView)
        
        arSceneView.translatesAutoresizingMaskIntoConstraints = false
        arSceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        arSceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        arSceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        arSceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        // Set the view's delegate
        arSceneView.delegate = self
        
        // Show statistics such as fps and timing information
        arSceneView.showsStatistics = false
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        // Set the scene to the view
        arSceneView.scene = scene
        setupHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        arSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    /*
        // Override to create and configure nodes for anchors added to the view's session.
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let node = SCNNode()
         
            return node
        }
    */
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
       for node in (scene.rootNode.childNodes){
           if(node.name == "ship"){
               node.eulerAngles.z += rotateZ
               node.eulerAngles.y += rotateY
               node.eulerAngles.x += rotateX
           }
       }
    }
    
    func setupHUD(){
        
        settingsButton.sizeToFit()
        settingsButton.center.x = self.view.bounds.maxX - 50
        settingsButton.frame.origin.y = 20
        settingsButton.backgroundColor = UIColor(ciColor: .gray)
        settingsButton.addTarget(self, action: #selector(openSettingsMenu), for: .touchUpInside)
        hud.addSubview(settingsButton)
        
        addMinnowButton.backgroundColor = UIColor(ciColor: .blue)
        addMinnowButton.sizeToFit()
        addMinnowButton.center.x = self.view.bounds.minX + 50
        addMinnowButton.frame.origin.y = 20
        addMinnowButton.addTarget(self, action: #selector(addMinnow), for: .touchUpInside)
        hud.addSubview(addMinnowButton)
        hud.backgroundColor = UIColor(ciColor: .clear)
        self.view.addSubview(hud)
    }
    
    @objc func addMinnow(sender: UIButton!) {
        print("You added a minnow!")
        
        if let view = self.view.viewWithTag(8){
            view.removeFromSuperview()
            hud.backgroundColor = UIColor(ciColor: .clear)
            arSceneView.play(sender)
        }else{
            print("do nothing")
        }
    }
    
    @objc func openSettingsMenu(sender: UIButton!) {

        let menu = UIStackView()
        menu.axis = .vertical
        menu.distribution = .fillEqually
        menu.alignment = .fill
        menu.spacing = 10
        menu.translatesAutoresizingMaskIntoConstraints = false
        menu.tag = 8
        
        labelZ.text = "Rotate In Z Axis: \(sliderZ.value * 100.0)"
        sliderZ.sizeToFit()
        sliderZ.minimumValue = 0.0
        sliderZ.maximumValue = 0.05
        sliderZ.addTarget(self, action: #selector(rotateShipZ), for: .allEvents)
        
        labelX.text = "Rotate In X Axis: \(sliderX.value * 100.0)"
        sliderX.sizeToFit()
        sliderX.minimumValue = 0.0
        sliderX.maximumValue = 0.05
        sliderX.addTarget(self, action: #selector(rotateShipX), for: .allEvents)
        
        labelY.text = "Rotate In Y Axis: \(sliderY.value * 100.0)"
        sliderY.sizeToFit()
        sliderY.minimumValue = 0.0
        sliderY.maximumValue = 0.05
        sliderY.addTarget(self, action: #selector(rotateShipY), for: .allEvents)
        
        menu.insertArrangedSubview(labelX, at: 0)
        menu.insertArrangedSubview(sliderX, at: 1)
        menu.insertArrangedSubview(labelY, at: 2)
        menu.insertArrangedSubview(sliderY, at: 3)
        menu.insertArrangedSubview(labelZ, at: 4)
        menu.insertArrangedSubview(sliderZ, at: 5)
        menu.backgroundColor = UIColor(ciColor: .red)
        
        hud.addSubview(menu)
        menu.widthAnchor.constraint(equalToConstant: self.view.bounds.maxX * 0.5).isActive = true
        menu.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        menu.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        hud.backgroundColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9)
        arSceneView.pause(sender)
    }
    
    @objc func rotateShipX(sender: UISlider!){
        rotateX = sender.value
        labelX.text = "Rotate In X Axis: \(sender.value * 100.0)"
    }
    
    @objc func rotateShipY(sender: UISlider!){
        rotateY = sender.value
        labelY.text = "Rotate In Y Axis: \(sender.value * 100.0)"
    }
    
    @objc func rotateShipZ(sender: UISlider!){
        rotateZ = sender.value
        labelZ.text = "Rotate In Z Axis: \(sender.value * 100.0)"
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupHUD()
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
}
