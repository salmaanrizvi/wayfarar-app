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
import Pulley
import Crashlytics
import MapKit

class ARNearbyStationsViewController: UIViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    get { return UIStatusBarStyle.lightContent }
  }
  
  lazy var sceneLocationView = SceneLocationView();
  lazy var stationManager = StationManager.default;
  lazy var stationsInView: [Station] = [];
  lazy var isExpanded: Bool = false;
  var mapCenter: CGPoint;

  lazy var loader: ARTLoaderView = {
    let _loader = ARTLoaderView(frame: self.view.frame);
    _loader.translatesAutoresizingMaskIntoConstraints = false;
    self.view.addSubview(_loader);
    _loader.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true;
    _loader.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true;
    _loader.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true;
    _loader.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true;
    return _loader;
  }()

  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var debugBlur: UIVisualEffectView!
  @IBOutlet weak var debugStack: UIStackView!
  @IBOutlet weak var mapView: MKMapView!
  
  var rerun: Bool = false;
  var hasInitialized: Bool = false {
    didSet {
      if (hasInitialized) { self.startTrackingLocation(); }
      else { self.restartTracking(); }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad();
    self.view.backgroundColor = .clear;
    self.loader.show();
    self.setupButton();
    self.addTapGesture();
    self.setupMapView();
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated);

    self.sceneLocationView.locationDelegate = self;
    self.sceneLocationView.run();
    self.view.insertSubview(self.sceneLocationView, at: 0);
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews();
    self.sceneLocationView.frame = self.view.bounds;
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.sceneLocationView.pause();
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning();
    print("received memory warning");
    // Dispose of any resources that can be recreated.
  }
  
  func setupButton() {
    self.settingsButton.layer.cornerRadius = self.settingsButton.frame.height / 2;
    self.settingsButton.layer.shadowOpacity = 0.75;
    self.settingsButton.layer.shadowRadius = 8;
    self.settingsButton.layer.shadowOffset = CGSize(width: 0, height: 0);
    self.settingsButton.layer.shadowColor = UIColor.black.cgColor;
    self.settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside);
  }
  
  func addTapGesture() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(didTapScene));
    self.sceneLocationView.addGestureRecognizer(tapGestureRecognizer);
  }
  
  func setupMapView() {
    self.mapView.layer.cornerRadius = self.mapView.frame.height / 2;
    self.mapView.showsCompass = false;
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap));
    tapGesture.numberOfTapsRequired = 1;
    self.mapView.addGestureRecognizer(tapGesture);
  }
  
  @objc func didTapMap(_ recognizer: UITapGestureRecognizer) {
    if !isExpanded {
      //Expand the video
      UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
        self.mapCenter = self.mapView.center
        
        self.mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width)
        self.mapView.center = self.view.center
        self.mapView.layoutSubviews()
        
      }, completion: nil)
    } else {
      //Shrink the video again
      
      UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
        
        //16 x 9 is the aspect ratio of all HD videos
        
        self.mapView.center = self.mapCenter
        
        let height = self.view.frame.width * 9 / 16
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
        self.videoPlayerView.frame = videoPlayerFrame
        
        self.videoPlayerView.layoutSubviews()
        
      }, completion: nil)
    }
    
    isExpanded = !isExpanded
  }
  
  @objc func didTapSettings(_ sender: UIButton) {
    let open: Bool = true;
    NotificationCenter.default.post(name: .SettingsNotification, object: open);
  }
  
  @objc func didTapScene(withGestureRecognizer recognizer: UITapGestureRecognizer) {
    let tapLocation = recognizer.location(in: self.sceneLocationView);
    let hitTestResults = self.sceneLocationView.hitTest(tapLocation);
    
    if hitTestResults.first == nil {
      return self.hideStationDetail();
    }
    
    let maxIterations = 10;
    var iterations = 0;

    var tappedNode = hitTestResults.first?.node;
    while (tappedNode != nil && iterations < maxIterations) {
      if let stationNode = tappedNode as? StationNode {
        self.showStationDetails([stationNode.station]);
        return;
      }
      tappedNode = tappedNode?.parent;
      iterations += 1;
    }
  }
  
  func startTrackingLocation() {
    DispatchQueue.main.async {
      if (self.rerun) {
        let options: ARSession.RunOptions = [.resetTracking];
        self.sceneLocationView.run(options: options);
      }

      self.stationManager.delegate = self;
      self.stationManager.enableLocationServices();
      self.mapView.setUserTrackingMode(.followWithHeading, animated: true);
      self.loader.hide();
    }
  }
  
  func restartTracking() {
    DispatchQueue.main.async {
      self.loader.show();
      self.rerun = true;
    }
  }
  
  func removeOldNodes() {
    self.sceneLocationView.sceneNode?.childNodes.forEach({ node in
      self.sceneLocationView.removeLocationNode(locationNode: node as! LocationNode);
    });
  }
  
  func showStationDetails(_ stations: [Station]) {
    var trains: [[Train]] = [];
    for station in stations {
      trains.append(self.stationManager.getTrainsFor(station: station))
    }
    let object: [String: Any] = ["stations": stations, "trains": trains];
    NotificationCenter.default.post(name: .DrawerNotification, object: object);
  }
  
  func hideStationDetail() {
    NotificationCenter.default.post(name: .DrawerNotification, object: nil)
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
    let alert = UIAlertController(title: "Oops!", message: "Something went wrong. \(error)", preferredStyle: .alert)
    let okay = UIAlertAction(title: "Okay", style: .default, handler: nil);
    alert.addAction(okay);
    self.present(alert);
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
  func sceneLocationViewSessionWasInterrupted(_ session: ARSession) {
    self.hasInitialized = false;
  }
  
  func sceneLocationViewSessionInterruptionEnded(_ session: ARSession) {
    self.hasInitialized = true;
  }
  
  func sceneLocationViewSession(_ session: ARSession, didFailWithError error: Error) {
    print("scene location view did fail with error \(error)");
  }
  
  func sceneLocationViewCameraDidChangeTrackingState(session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    
    switch camera.trackingState {
      case .normal: self.hasInitialized = true;
      case .notAvailable: print("not available");
      case .limited(.initializing): print("initializing");

      case .limited(.excessiveMotion):
        print("excessive motion");
        self.hasInitialized = false;

      case .limited(.insufficientFeatures):
        print("insufficient features");
        self.hasInitialized = false;
    }
  }
  
  func sceneLocationViewNodeDidMoveIntoView(_ locatioNodes: [LocationNode]) {
    var stations: [Station] = [];
    locatioNodes.forEach({
      if let stationNode = $0 as? StationNode {
        stations.append(stationNode.station);
      }
    });
    
    if (stations.isEmpty) { self.hideStationDetail(); }
    if (stations == self.stationsInView) { return; }

    self.stationsInView = stations;
    self.showStationDetails(self.stationsInView)
  }
}
