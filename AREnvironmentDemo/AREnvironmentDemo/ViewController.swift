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
    
    //The augmented reality view
    let arSceneView = ARSCNView(frame: UIScreen.main.bounds)
    //The heads up display view
    var hud = SCNView(frame: UIScreen.main.bounds)
    //Our actual content scene
    var scene = SCNScene()
    //Some dummy interface objects for demo purposes
        var rotateZ: Float = 0.0
        var rotateX: Float = 0.0
        var rotateY: Float = 0.0
        var labelX = UILabel()
        var labelY = UILabel()
        var labelZ = UILabel()
        var sliderX = UISlider()
        var sliderY = UISlider()
        var sliderZ = UISlider()
        var settingsButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(arSceneView)
        
        //Set some constraints to place the ar scene view in full screen
        arSceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        arSceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
        arSceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
        arSceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
        arSceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        // Set the view's delegate
        arSceneView.delegate = self
        
        // Show statistics such as fps and timing information (Add in menu option)
        arSceneView.showsStatistics = false
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        //Scale the ship down and place it in front of the camera
        for node in (scene.rootNode.childNodes){
            if(node.name == "ship"){
                node.scale = SCNVector3Make(0.25, 0.25, 0.25)
                node.position = SCNVector3Make(0.0, 0.0, -0.5)
            }
        }
        
        // Set the scene to the view
        arSceneView.scene = scene
        setupHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arSceneView.debugOptions = [.showFeaturePoints, .showPhysicsFields, .showWorldOrigin]
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.addChildNode(createSurfacePlane(planeAnchor: planeAnchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updateSurfacePlane(node: node, anchor: anchor)
    }
    
    func createSurfacePlane(planeAnchor: ARPlaneAnchor) -> SCNNode{
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let center = planeAnchor.center
        
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor(displayP3Red: CGFloat.random(in: 0..<1), green: CGFloat(Float.random(in: 0..<1)), blue: CGFloat(Float.random(in: 0..<1)), alpha: CGFloat.random(in: 0..<1))
        
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(center)
        planeNode.eulerAngles.x = -.pi / 2
        return planeNode
    }
    
    func updateSurfacePlane(node: SCNNode, anchor: ARAnchor){
        
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let center = planeAnchor.center
        plane.width = width
        plane.height = height
        
        planeNode.position = SCNVector3(center)
        
    }
    
    //Called each render cycle
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //Every frame apply some change to the ships euler angles
       for node in (scene.rootNode.childNodes){
           if(node.name == "ship"){
               node.eulerAngles.z += rotateZ
               node.eulerAngles.y += rotateY
               node.eulerAngles.x += rotateX
           }
       }
    }
    
    //Create the heads up display layer
    func setupHUD(){
        //Unique tag for adding / removing the settings button
        settingsButton.tag = 21
        //Set the image for the button
        settingsButton.setImage(UIImage(named: "gears"), for: .normal)
        //Appropriately scale image
        settingsButton.imageView?.contentMode = .scaleAspectFit
        //Set some padding for the image inside the button
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        //Button background color
        settingsButton.backgroundColor = UIColor(displayP3Red: 0.25, green: 0.25, blue: 0.25, alpha: 0.6)
        //Give the button a corner radius
        settingsButton.layer.cornerRadius = 3.0
        //Add our open settings menu function to the button
        settingsButton.addTarget(self, action: #selector(openSettingsMenu), for: .touchUpInside)
        //Add our button the heads up display
        hud.addSubview(settingsButton)
        
        //Set some layout constraints for the button
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(equalTo: hud.trailingAnchor, constant: -(hud.bounds.width * 0.05)),
            settingsButton.topAnchor.constraint(equalTo: hud.topAnchor, constant: (hud.bounds.height * 0.025)),
            settingsButton.widthAnchor.constraint(equalToConstant: 48.0),
            settingsButton.heightAnchor.constraint(equalToConstant: 48.0)
        ])
        
        //Set our heads up display background color to transparent
        hud.backgroundColor = UIColor(ciColor: .clear)
        //Add the heads up display to the main view
        self.view.addSubview(hud)
    }
    
    //Close the settings menu
    @objc func closeMenu(sender: UIButton!){
        //Remove the entire settings menu view from the view hierarchy
        if let view = self.view.viewWithTag(8){
            view.removeFromSuperview()
            //Remove the close menu button
            self.view.viewWithTag(11)?.removeFromSuperview()
            //Setup our heads up display
            setupHUD()
            //Resume rendering the augmented reality scene
            arSceneView.play(sender)
        }else{
            print("explosion")
        }
    }
    
    //Open the settings menu
    @objc func openSettingsMenu(sender: UIButton!) {
        
        //Remove the settings button and add a close settings button
        if let button = self.view.viewWithTag(21){
            button.removeFromSuperview()
            //Create our close menu button
            let closeMenuButton = UIButton()
            //Set the button image
            closeMenuButton.setImage(UIImage(named: "close"), for: .normal)
            //Appropriately scale the button image
            closeMenuButton.imageView?.contentMode = .scaleAspectFit
            //Add some padding to the button image
            closeMenuButton.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            //Set button background color to a soft red
            closeMenuButton.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.25, blue: 0.25, alpha: 0.6)
            //Add a little corner radius to the button
            closeMenuButton.layer.cornerRadius = 3.0
            //Add our close menu function to the button
            closeMenuButton.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
            //Set a unique tag so we can find and remove this button later
            closeMenuButton.tag = 11
            //Add the button to the heads up display
            hud.addSubview(closeMenuButton)
            //Set some layout constraints for the button
            closeMenuButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeMenuButton.trailingAnchor.constraint(equalTo: hud.trailingAnchor, constant: -(hud.bounds.width * 0.05)),
                closeMenuButton.topAnchor.constraint(equalTo: hud.topAnchor, constant: (hud.bounds.height * 0.025)),
                closeMenuButton.widthAnchor.constraint(equalToConstant: 48.0),
                closeMenuButton.heightAnchor.constraint(equalToConstant: 48.0)
            ])
        }
        
        //Create a scroll view so we can have a longer menu we can scroll through if necessary
        let scrollContainer = UIScrollView()
        //Give the scroll view a unique identifier
        scrollContainer.tag = 8
        //Set the background to a soft grey
        scrollContainer.backgroundColor = UIColor(displayP3Red: 0.25, green: 0.25, blue: 0.25, alpha: 0.6)
        //Give the view a nice corner radius
        scrollContainer.layer.cornerRadius = 10.0
        //Add the view to the heads up display
        hud.addSubview(scrollContainer)
        
        //Set some constraints for the scroll view
        scrollContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollContainer.centerYAnchor.constraint(equalTo: hud.centerYAnchor),
            scrollContainer.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            scrollContainer.widthAnchor.constraint(equalToConstant: hud.bounds.maxX * 0.75),
            scrollContainer.heightAnchor.constraint(equalToConstant: hud.bounds.maxY * 0.75)
        ])
        
        //Create our actual menu, a stack view that is embedded in the scroll view
        let menu = UIStackView()
        scrollContainer.addSubview(menu)
        
        //Setup stack view properties
        menu.axis = .vertical
        menu.distribution = .fillEqually
        menu.alignment = .center
        menu.spacing = 8
        menu.translatesAutoresizingMaskIntoConstraints = false
        
        //Add some demo sliders to rotate the ship
        labelZ.text = "Rotate In Z Axis: \(sliderZ.value * 100.0)"
        sliderZ.minimumValue = 0.0
        sliderZ.maximumValue = 0.05
        sliderZ.addTarget(self, action: #selector(rotateShipZ), for: .allEvents)
            labelX.text = "Rotate In X Axis: \(sliderX.value * 100.0)"
            sliderX.minimumValue = 0.0
            sliderX.maximumValue = 0.05
            sliderX.addTarget(self, action: #selector(rotateShipX), for: .allEvents)
                labelY.text = "Rotate In Y Axis: \(sliderY.value * 100.0)"
                sliderY.minimumValue = 0.0
                sliderY.maximumValue = 0.05
                sliderY.addTarget(self, action: #selector(rotateShipY), for: .allEvents)
        
        //Add our content to the stack view
        menu.addArrangedSubview(labelX)
        menu.addArrangedSubview(sliderX)
        menu.addArrangedSubview(labelY)
        menu.addArrangedSubview(sliderY)
        menu.addArrangedSubview(labelZ)
        menu.addArrangedSubview(sliderZ)
        
        //Set some constraints for the demo sliders
        NSLayoutConstraint.activate([
            sliderX.widthAnchor.constraint(equalTo: menu.widthAnchor, multiplier: 0.8),
            sliderY.widthAnchor.constraint(equalTo: menu.widthAnchor, multiplier: 0.8),
            sliderZ.widthAnchor.constraint(equalTo: menu.widthAnchor, multiplier: 0.8)
        ])
        
        //Making some dummy buttons to test the scroll view
        for x in 0...9{
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = UIColor.green
            
            menu.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 40.0),
                button.widthAnchor.constraint(equalToConstant: 200.0)
            ])
            
            button.setTitle("Test Button: \(x)", for: .normal)
        }
        
        //Set some layout constraints for the menu to fill up the scroll view
        NSLayoutConstraint.activate([
            //This stretches the scroll container to the bottom of its content
            scrollContainer.bottomAnchor.constraint(equalTo: menu.bottomAnchor),
            menu.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
            menu.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor),
            menu.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            menu.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor),
            menu.widthAnchor.constraint(equalTo: scrollContainer.widthAnchor)
        ])
        
        //Set the background color of the entire heads up display to a transparent grey
        hud.backgroundColor = UIColor(displayP3Red: 0.25, green: 0.25, blue: 0.25, alpha: 0.5)
        //Pause the ar scene while editing settings
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
    
    func createTank(){
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //setupHUD()
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
