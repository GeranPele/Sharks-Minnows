//
//  GameViewController.swift
//  Sharks&Minnows2.0
//
//  Created by Geran Pele on 5/14/18.
//  Copyright © 2018 Geran Pele. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit

class GameViewController: UIViewController, SCNSceneRendererDelegate{
    
    //Implement forces from cohesion, alignment & separation into the scene to effect the scene itself and the objects inside it
    //Ideally the fish would have some awareness of the scene and not run into objects
    
    var pebbles: [Pebble] = []
    var minnows: [Minnow] = []
    //var minnows: [SCNNode] = []
    var scene: SCNScene!
    

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
        
        
        /*
        //School of fish!:
        for _ in 1...1 {
            
            //Fish Node:
            let fishNode = SCNNode()
            let fishScene = SCNScene(named: "art.scnassets/Fish.scn")
            let fishArray = fishScene?.rootNode.childNodes
            
            //Grab all the fish parts:
            for childNode in fishArray! {
                fishNode.addChildNode(childNode as SCNNode)
            }
            
            let rollX: GKRandomDistribution = GKRandomDistribution(lowestValue: -10, highestValue: 10)
            let rollY: GKRandomDistribution = GKRandomDistribution(lowestValue: -5, highestValue: 5)
            let rollZ: GKRandomDistribution = GKRandomDistribution(lowestValue: 1, highestValue: 8)
            
            fishNode.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
            fishNode.scale = SCNVector3Make(0.25, 0.25, 0.25)
            fishNode.position = SCNVector3Make(rollX.nextUniform(), rollZ.nextUniform(), rollY.nextUniform())
            
            scene.rootNode.addChildNode(fishNode)
            minnows.append(fishNode)
        }
        */
        
        for _ in 1 ... 1{
            
            let origin = SCNVector3Make(0.0, 10.0, 0.0)
            let minnow: Minnow = Minnow(origin: origin)
            minnows.append(minnow)
            
            //Make dummy node here
            //Update every frame
            //Set to position + velocity
            //Either create a dummy node in the minnow class or create them here and update every frame
            //Implementation not working because dummy nodes are not in the scene graph
        }
        
        //Materials and Geometry:
        for m in minnows{
            
            //Grab all the fish parts:
            let fishNode = SCNNode()
            let fishScene = SCNScene(named: "art.scnassets/Fish.scn")
            let nodeArray = fishScene?.rootNode.childNodes
            
            for childNode in nodeArray! {
                //Appropriate for grouping physics??
                fishNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                fishNode.addChildNode(childNode as SCNNode)
            }
            
            fishNode.position = m.location
            fishNode.scale = SCNVector3Make(0.25, 0.25, 0.25)
            fishNode.eulerAngles = SCNVector3Make(-.pi/2.0, 0.0, 0.0)
            //fishNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            
            m.addChildNode(fishNode)
            
            //Make leading node run minnow movement operations???
            //let lac = SCNLookAtConstraint(target: m.leadingNode)
            //m.constraints = [lac]
            scene.rootNode.addChildNode(m)
        }

        /*
        //Castle node:
        let castleNode = SCNNode()
        let castleScene = SCNScene(named: "art.scnassets/Castle.scn")
        let castleArray = castleScene?.rootNode.childNodes
        
        //Grab all the castle parts:
        for childNode in castleArray!{
            castleNode.addChildNode(childNode)
        }
        
        castleNode.position = SCNVector3Make(2.0, 0.0, 7.0)
        castleNode.eulerAngles = SCNVector3Make(-.pi/2.0, -.pi/3.0, 0.0)
        //Pretty good scale for the castle:
        castleNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
        scene.rootNode.addChildNode(castleNode)
        */
        
        let rock1Node = SCNNode()
        let rock1Scene = SCNScene(named: "art.scnassets/Rock1.scn")
        let rock1Array = rock1Scene?.rootNode.childNodes
        
        for childNode in rock1Array!{
            rock1Node.addChildNode(childNode)
        }
        
        rock1Node.position = SCNVector3Make(2.0, 0.0, -5.0)
        rock1Node.eulerAngles = SCNVector3Make(-.pi/2.0, -.pi/2.0, 0.0)
        rock1Node.scale = SCNVector3Make(0.75, 0.75, 0.75)
        //scene.rootNode.addChildNode(rock1Node)
        
        /*
        let rock2Node = SCNNode()
        let rock2Scene = SCNScene(named: "art.scnassets/Rock2.scn")
        let rock2Array = rock2Scene?.rootNode.childNodes
        
        for childNode in rock2Array!{
            rock2Node.addChildNode(childNode)
        }
        
        rock2Node.position = SCNVector3Make(0.0, 0.0, 0.0)
        rock2Node.eulerAngles = SCNVector3Make(-.pi/2.0, -.pi/2.0, 0.0)
        //rock2Node.scale = SCNVector3Make(0.75, 0.75, 0.75)
        scene.rootNode.addChildNode(rock2Node)
        
        let rock3Node = SCNNode()
        let rock3Scene = SCNScene(named: "art.scnassets/Rock3.scn")
        let rock3Array = rock3Scene?.rootNode.childNodes
        
        for childNode in rock3Array!{
            rock3Node.addChildNode(childNode)
        }
        
        rock3Node.position = SCNVector3Make(0.0, 0.0, 5.0)
        rock3Node.eulerAngles = SCNVector3Make(-.pi/2.0, -.pi/2.0, 0.0)
        //rock2Node.scale = SCNVector3Make(0.75, 0.75, 0.75)
        scene.rootNode.addChildNode(rock3Node)
        */
        
        //How to make aquarium phyics work???
        //Scale of physics body must be the same as geometry!
        //Aquarium may need to have walls combined?
        //Aquarium walls are boxes that are up-scaled, they need to physically be created!!
        //Lets programmatically add rocks with physics bodies!:

        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        let backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        scnView.backgroundColor = backgroundColor
        
        //Set sceneView as a delegate to SCNSceneRenderer to override the renderer function:
        scnView.delegate = self as SCNSceneRendererDelegate
        //Continue updating frames:
        scnView.isPlaying = true
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        /*
        if pebbles.count < 50 {
            let origin = SCNVector3Make(0.0, 10.0, 0.0)
            let peb = Pebble(location: origin)
            //peb.update()
            pebbles.append(peb)
            scene.rootNode.addChildNode(peb)
        }
         */
        //Check if the pebble has reached a ture 'resting state' (check gravity) and change to static
        //Maybe setup the pebbles below the fish to simplify the scene
        /*
        while pebbles.count < 50{
            
            let rollX: GKRandomDistribution = GKRandomDistribution(lowestValue: -2, highestValue: 2)
            //let rollY: GKRandomDistribution = GKRandomDistribution(lowestValue: -1, highestValue: 1)
            let rollZ: GKRandomDistribution = GKRandomDistribution(lowestValue: 1, highestValue: 5)
            
            
            let rockTestGeometry = SCNBox(width: CGFloat(drand48()), height: CGFloat(drand48()), length: CGFloat(drand48()), chamferRadius: 0.0625)
            
            let color = UIColor(displayP3Red: 0.3647, green: 0.5961, blue: 0.8667, alpha: 1.0)
            rockTestGeometry.firstMaterial?.diffuse.contents = color
            let rockTest = SCNNode(geometry: rockTestGeometry)
            rockTest.position = SCNVector3Make(rollX.nextUniform(), 10.0, rollZ.nextUniform())
            rockTest.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            
            //rockTest.physicsBody?.restitution = 0.2
            //pebbles.append(rockTest)
            //scene.rootNode.addChildNode(rockTest)
        }
         */
        
        /*
        for p in pebbles{
                p.update()
            //p.update()
            //Swift.print(p.location)
            //Swift.print(p.position)
            if p.position.y < 3.0{
                
                Swift.print("Boom")
                //Swift.print(p.position)
                //p.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
                //p.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        }
    }
        */
        
        
        for m in minnows{
            let force = m.seek(target: SCNVector3Make(5.0, 1.0, 1.0))
            
            //Instantaneous application:
            m.physicsBody?.applyForce(force, asImpulse: true)
            //Summation of all forces:
            //m.physicsBody?.applyForce(force, asImpulse: false)
           // m.update()
            
            Swift.print(force, m.location, m.position)
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
