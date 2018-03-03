//
//  ARNearbyStationsViewController.swift
//  wayfarer
//
//  Created by Salmaan on 2/18/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation
import ARKit

class ARNearbyStationsViewController: UIViewController {
  lazy var sceneLocationView = SceneLocationView();
  lazy var stationManager = StationManager();

  @IBOutlet weak var debugBlur: UIVisualEffectView!
  @IBOutlet weak var debugStack: UIStackView!
  
  var hasInitialized: Bool = false {
    didSet {
      self.initializeTracking();
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad();
    self.stationManager.delegate = self;
    self.stationManager.enableLocationServices();
    self.sceneLocationView.locationDelegate = self;
    self.sceneLocationView.run();
    
    self.view.addSubview(self.sceneLocationView);
    
    self.view.bringSubview(toFront: self.debugBlur);
    self.view.bringSubview(toFront: self.debugStack);
      // Do any additional setup after loading the view.
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews();
    self.sceneLocationView.frame = self.view.bounds;
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.sceneLocationView.pause();
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func initializeTracking() {
    
  }
  
  func removeOldNodes() {
    self.sceneLocationView.sceneNode?.childNodes.forEach({ node in
      self.sceneLocationView.removeLocationNode(locationNode: node as! LocationNode);
    });
  }
}

///MARK: StationManagerDelegate methods
extension ARNearbyStationsViewController: StationManagerDelegate {
  func stationManager(_ manager: StationManager, didUpdateStations stations: [Station]?, withTrains trains: [[Train]]) {
    guard let stations = stations, let userLoc = manager.location else { return; }
    
    DispatchQueue.main.sync {
      self.removeOldNodes();
      
      for station in stations {
        let stationNode = StationNode(station: station, userLoc: userLoc);
        self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: stationNode);
      }
    }
  }
  
  func stationManager(_ manager: StationManager, didFailUpdateWithError error: Error) {
    print("failed to update stations with error", error);
  }
  
  func stationManager(_ manager: StationManager, updatedHeading heading: CLHeading, andCalculatedHeading calculated: CLLocationDirection?) {
    
    let magneticHeading = heading.magneticHeading;
    let trueHeading = heading.trueHeading;
    let direction = trueHeading.toCompassDirection();
    
    if let dirLabel = self.debugStack.arrangedSubviews.get(index: 0) as? UILabel {
      dirLabel.text = direction
    }
    
    if let trueLabel = self.debugStack.arrangedSubviews.get(index: 1) as? UILabel {
      trueLabel.text = "True: \(trueHeading.roundedToNearest(0.01))";
    }
    
    if let magLabel = self.debugStack.arrangedSubviews.get(index: 2) as? UILabel {
      magLabel.text = "Mag: \(magneticHeading.roundedToNearest(0.01))";
    }
    
    if let calcLabel = self.debugStack.arrangedSubviews.get(index: 3) as? UILabel {
      if calculated != nil {
        calcLabel.text = "Calc: \(calculated!.roundedToNearest(10))";
      }
      else { calcLabel.text = "Calc: N/A"; }
    }
  }
}

extension ARNearbyStationsViewController: SceneLocationViewDelegate {
  func sceneLocationViewCameraDidChangeTrackingState(session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    
    switch camera.trackingState {
    case .normal: self.hasInitialized = true;
    case .notAvailable: print("not available");
    case .limited(.initializing): print("initializing");
    case .limited(.excessiveMotion): print("excessive motion");
    case .limited(.insufficientFeatures): print("insufficient features");
    }
  }
  
  func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {}
  func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {}
  func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {}
  func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {}
  func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {}
}
