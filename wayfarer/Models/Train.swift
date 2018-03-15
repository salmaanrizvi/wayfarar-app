//
//  Train.swift
//  wayfarer
//
//  Created by Salmaan on 2/6/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import DateToolsSwift

struct Arrivals: Codable {
  var northbound: [Train]
  var southbound: [Train]
  
  private enum CodingKeys: String, CodingKey {
    case northbound = "N"
    case southbound = "S"
  }
}


struct Train: Codable, CustomStringConvertible {
  var id: String
  var lastUpdated: Double
  var currentStatus: String
  var timestamp: String
  var currentStopSequence: Int
  var direction: String
  var route: String
  var trainId: String
  var stops: [Stop]
  var alerts: [Alert]
  var towards: String
  
  init(id: String, trainId: String, lastUpdated: Double, currentStatus: String, timestamp: String, direction: String, route: String, stops: [Stop], alerts: [Alert], towards: String, currentStopSequence: Int?) {
    self.id = id;
    self.trainId = trainId;
    self.lastUpdated = lastUpdated;
    self.currentStatus = currentStatus;
    self.direction = direction;
    self.route = route;
    self.stops = stops;
    self.currentStopSequence = currentStopSequence ?? 0;
    self.timestamp = timestamp;
    self.alerts = alerts
    self.towards = towards
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(String.self, forKey: .id);
    let lastUpdated = try container.decode(Double.self, forKey: .lastUpdated);
    let currentStatus = try container.decode(String.self, forKey: .currentStatus);
    let timestamp = try container.decode(String.self, forKey: .timestamp);
    let direction = try container.decode(String.self, forKey: .direction);
    let route = try container.decode(String.self, forKey: .route);
    let trainId = try container.decode(String.self, forKey: .trainId);
    let stops = try container.decode([Stop].self, forKey: .stops);
    let alerts = try container.decode([Alert].self, forKey: .alerts);
    let towards = try container.decode(String.self, forKey: .towards);
    
    var currentStopSeq: Int?;
    
    do { currentStopSeq = try container.decodeIfPresent(Int.self, forKey: .currentStopSequence); }
    catch {
//      print("Could not decode current stop sequence as int for train \(trainId)");
    }
    
    do {
      let currentStopSeqVal = try container.decodeIfPresent(String.self, forKey: .currentStopSequence) ?? "0";
      print("decoded current stop sequence to \(currentStopSeqVal)");
      currentStopSeq = Int(currentStopSeqVal);
    }
    catch {
//      print("Also could not decode it as string for train \(trainId)")
    }

    self.init(id: id,
              trainId: trainId,
              lastUpdated: lastUpdated,
              currentStatus: currentStatus,
              timestamp: timestamp,
              direction: direction,
              route: route,
              stops: stops,
              alerts: alerts,
              towards: towards,
              currentStopSequence: currentStopSeq);
  }
  
  private enum CodingKeys: String, CodingKey {
    case id = "_id"
    case lastUpdated
    case currentStatus = "current_status"
    case timestamp
    case currentStopSequence = "current_stop_seq"
    case direction
    case route
    case trainId = "train_id"
    case stops
    case alerts
    case towards
  }
  
  var description: String {
    let firstStop = stops.get(index: 0)?.description ?? "N/A";
    return "\nTrain ID: \(trainId)"
      + "\nRoute: \(route)"
      + "\nDirection: \(direction)"
      + "\nTowards: \(towards)"
      + "\nStops:\(stops.count)"
      + "\nCurrent Status: \(currentStatus)"
      + "\nCurrent Stop Sequence: \(currentStopSequence)"
      + "\nFirst Stop in Stops\(firstStop)"
      + "\nLast Updated: \(Date(timeIntervalSince1970: lastUpdated))\n";
  }
}

struct Stop: Codable, CustomStringConvertible {
  var stationId: String
  var stationName: String
  var arrivalTime: TimeInterval

  var formattedDate: String {
    get {
      let timeAgo = Date(timeIntervalSince1970: self.arrivalTime).shortTimeAgoSinceNow;
      return "in " + timeAgo.replacingOccurrences(of: "m", with: " min");
    }
    // DateFormatter.parseTime(self.arrivalTime); }
  }
  
  private enum CodingKeys: String, CodingKey {
    case stationId = "station_id"
    case stationName = "station_name"
    case arrivalTime
  }
  
  var description: String {
    return "\(stationId) - \(stationName) - \(formattedDate) - \(arrivalTime)"
  }
}

struct Alert: Codable {
  var cause: String
  var effect: String
  var text: String
  
  private enum CodingKeys: String, CodingKey {
    case cause
    case effect
    case text
  }
}
