//
//  ViewController.swift
//  wayfarer
//
//  Created by Salmaan on 10/25/17.
//  Copyright © 2017 Salmaan Rizvi. All rights reserved.
//

import ARKit
import UIKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self;
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true;

        self.addTapGesture();
        self.addBox();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration();

        // Run the view's session
        sceneView.session.run(configuration);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        // Pause the view's session
        sceneView.session.pause();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }   
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.5) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 1, chamferRadius: 0);
        
        let boxNode = SCNNode();
        boxNode.castsShadow = true;
        boxNode.geometry = box;
        boxNode.position = SCNVector3(x, y, z); 

        self.sceneView.scene.rootNode.addChildNode(boxNode);
    }
    
    func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap));
        self.sceneView.addGestureRecognizer(tapGestureRecognizer);
    }

    @objc func didTap(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self.sceneView);
        let hitTestResults = self.sceneView.hitTest(tapLocation);

        guard let tappedNode = hitTestResults.first?.node else {
            let featurePointHitTest = self.sceneView.hitTest(tapLocation, types: .featurePoint);
            if let result = featurePointHitTest.first {
                let location = result.worldTransform.translation;
                self.addBox(x: location.x, y: location.y, z: location.z);
            }
            return
        }
        tappedNode.removeFromParentNode();
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3;
        return float3(x: translation.x, y: translation.y, z: translation.z);
    }
}
