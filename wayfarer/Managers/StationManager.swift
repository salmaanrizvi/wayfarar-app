//
//  StationManager.swift
//  wayfarer
//
//  Created by Salmaan on 2/18/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol StationManagerDelegate {
  func stationManager(_ manager: StationManager,
                      didUpdateStations stations: [Station]?,
                      withTrains trains: [[Train]]);

  func stationManager(_ manager: StationManager, didFailUpdateWithError error: Error);
  
  func stationManager(_ manager: StationManager, updatedHeading heading: CLHeading, andCalculatedHeading calculated: CLLocationDirection?)
}

public class StationManager: NSObject {
  
  lazy var locationManager = CLLocationManager();
  lazy var lastFourLocations: [CLLocation] = [];

  lazy var trains: [[Train]] = []
  var nearbyTransit: NearbyTransit?
  var delegate: StationManagerDelegate?
  
  public var location: CLLocation? { get { return self.locationManager.location } }
  
  override init() {
    super.init();
    self.locationManager.delegate = self;
  }
  
  func enableLocationServices() {
    self.locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.delegate = self;
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
      self.locationManager.distanceFilter = 10.0; // in meters
      self.locationManager.headingOrientation = .portrait;
//      self.locationManager.headingFilter = 10; // in degrees.
      
      self.locationManager.startUpdatingLocation();
      self.locationManager.startUpdatingHeading();
    }
  }
  
  func requestNearbyStations() {
    if self.locationManager.location == nil { return; }
    self.loadTrains(self.locationManager.location!.coordinate) { error in
      if let e = error { self.delegate?.stationManager(self, didFailUpdateWithError: e)}
      else {
        self.delegate?.stationManager(self,
                                      didUpdateStations: self.nearbyTransit?.stations,
                                      withTrains: self.trains);
      }
    }
  }
  
  fileprivate func filterTrainsForStations() {
    guard let nearbyTransit = self.nearbyTransit else { return; }
    self.trains = [];
    
    nearbyTransit.stations.forEach({ station in
      var nFiltered = nearbyTransit.trains.northbound.filter({ train -> Bool in
        return train.stops.index(where: { $0.stationId.index(of: station.stopId) != nil }) != nil;
      });
      
      let sFiltered = nearbyTransit.trains.southbound.filter({ train -> Bool in
        return train.stops.index(where: { $0.stationId.index(of: station.stopId) != nil }) != nil;
      });
      
      nFiltered.append(contentsOf: sFiltered);
      self.trains.append(nFiltered);
    });
    
    print("Have \(nearbyTransit.stations.count) stations");
  }
}

//MARK: CLLocationManagerDelegate
extension StationManager: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location else { return; }
    
    // don't save invalid location updates
    if (location.horizontalAccuracy < 0) {
      print("filtering inaccurate location--");
      return;
    }
    
    if (-location.timestamp.timeIntervalSinceNow > 10.0) {
      print("filtering location update older than 5 seconds")
      return;
    }

    self.saveLocation(location);
    self.loadTrains(location.coordinate) { error in
      if let e = error { self.delegate?.stationManager(self, didFailUpdateWithError: e) }
      else {
        self.delegate?.stationManager(self,
                                      didUpdateStations: self.nearbyTransit?.stations,
                                      withTrains: self.trains);
      }
    }
  }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Could not get location for user", error);
    if self.locationManager.location != nil {
      print("Last location on device for user", self.locationManager.location!);
    }
  }
  
  public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    var calculatedHeading: CLLocationDirection? = nil;

    if let lastLoc = self.lastFourLocations.get(index: 3),
      let secondToLast = self.lastFourLocations.get(index: 2) {
      
      calculatedHeading = CLLocation.headingFrom(source: secondToLast, to: lastLoc);
    }
    
    self.delegate?.stationManager(self, updatedHeading: newHeading, andCalculatedHeading: calculatedHeading)
  }
  
  private func loadTrains(_ coordinate: CLLocationCoordinate2D, _ cb: @escaping (_ error: Error?) -> () = { _ in }) {    
    APIManager.shared.getNearbyTrains(coordinate, completion: { (err, transit) in
      if let nearby = transit {
        self.nearbyTransit = nearby;
        self.filterTrainsForStations();
        return cb(nil)
      }
      return cb(err);
    });
  }
  
  private func saveLocation(_ loc: CLLocation) {
    self.lastFourLocations.append(loc);
    if self.lastFourLocations.count > 4 {
      self.lastFourLocations.removeFirst(self.lastFourLocations.count - 4);
    }
  }
}
