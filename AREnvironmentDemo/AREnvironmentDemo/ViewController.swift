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
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
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
    func setupHUD(){
        
        let addMinnowButton = UIButton()
        let settingsButton = UIButton()
        
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
        hud.backgroundColor = UIColor(displayP3Red: 0.1, green: 0.1, blue: 0.1, alpha: 0.3)
        
        self.view.addSubview(hud)
    }
    
    @objc func addMinnow(sender: UIButton!) {
        print("You added a minnow!")
    }
    
    @objc func openSettingsMenu(sender: UIButton!) {
        //Should also pause the animations in the background

        let menu = UIStackView()
        menu.axis = .vertical
        menu.distribution = .fillEqually
        menu.alignment = .fill
        menu.spacing = 10
        menu.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0...4{
            let slider = UISlider()
            slider.sizeToFit()
            slider.minimumValue = 0
            slider.maximumValue = 100
            menu.addArrangedSubview(slider)
        }
        hud.addSubview(menu)
        menu.widthAnchor.constraint(equalToConstant: self.view.bounds.maxX * 0.5).isActive = true
        menu.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        menu.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
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
