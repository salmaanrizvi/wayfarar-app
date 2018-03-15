//
//  Station.swift
//  wayfarer
//
//  Created by Salmaan on 2/6/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import CoreLocation

struct NearbyTransit: Codable {
  var stations: [Station]
  var trains: Arrivals
  
  private enum CodingKeys: String, CodingKey {
    case stations
    case trains
  }
}

func ==(lhs: Station, rhs: Station) -> Bool {
  return lhs.id == rhs.id;
}

struct Station: Codable, Equatable {
  var id: String
  var stopName: String
  var borough: String
  var line: String
  var stopId: String
  var lastUpdated: Double?
  var daytimeRoutes: [String]
  var entrances: [Entrance]
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var currentTrains: CurrentTrain

  lazy var location: CLLocation = {
    let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude);
    let altitude = StationManager.default.location?.altitude ?? MINIMUM_ALTITUDE
    return CLLocation(coordinate: coordinate, altitude: altitude);
  }();
  
  mutating func entranceLoc(to location: CLLocation) -> CLLocation {
    if (self.entrances.isEmpty) {
      return self.location;
//      return CLLocation(latitude: self.latitude, longitude: self.longitude);
    }
    
    var closestEntrance: Entrance?
    var lowestDistance: CLLocationDistance?
    
    self.entrances.forEach({ entr in
      var entrance = entr;
      let dist = location.distance(from: entrance.location, roundedTo: 1);
      if (lowestDistance == nil || dist < lowestDistance!) {
        lowestDistance = dist;
        closestEntrance = entrance;
      }
    });
    
    let altitude: CLLocationDistance = min(lowestDistance!, StationManager.default.location?.altitude ?? MINIMUM_ALTITUDE);
    return CLLocation(coordinate: closestEntrance!.location.coordinate, altitude: altitude);
  }

  func nearestEntrance(to location: CLLocation) -> String {
    let format = "%.0f";

    if (self.entrances.isEmpty) {
      var entr = Entrance(latitude: self.latitude, longitude: self.longitude, corner: "", location: nil);
      let distance = location.distance(from: entr.location, roundedTo: 1);
      return String.localizedStringWithFormat(format, distance) + "m";
    }

    var closestEntrance: Entrance?
    var lowestDistance: CLLocationDistance?

    self.entrances.forEach({ entr in
      var entrance = entr;
      let dist = location.distance(from: entrance.location, roundedTo: 1);
      if (lowestDistance == nil || dist < lowestDistance!) {
        lowestDistance = dist;
        closestEntrance = entrance;
      }
    });

    return "\(closestEntrance!.corner) - " + String.localizedStringWithFormat(format, lowestDistance!) + "m";
  }
  
  func getLocation(from loc: CLLocation) -> CLLocation {
    let stationLoc = CLLocation(latitude: self.latitude, longitude: self.longitude);
    let distance = loc.distance(from: stationLoc);
    return CLLocation(coordinate: stationLoc.coordinate, altitude: distance / 10);
  }
  
  private enum CodingKeys: String, CodingKey {
    case id = "_id"
    case stopName = "stop_name"
    case borough
    case line
    case stopId = "stop_id"
    case lastUpdated
    case daytimeRoutes = "daytime_routes"
    case entrances
    case latitude = "stop_lat"
    case longitude = "stop_lon"
    case currentTrains = "trains"
  }
}

struct Entrance: Codable {
  var latitude: CLLocationDegrees
  var longitude: CLLocationDegrees
  var corner: String
  
  lazy var location: CLLocation = {
    return CLLocation(latitude: self.latitude, longitude: self.longitude);
  }();
  
  private enum CodingKeys: String, CodingKey {
    case corner
    case latitude
    case longitude
  }
}

struct CurrentTrain: Codable {
  var northbound: [String]
  var southbound: [String]
  
  private enum CodingKeys: String, CodingKey {
    case northbound = "N"
    case southbound = "S"
  }
}
