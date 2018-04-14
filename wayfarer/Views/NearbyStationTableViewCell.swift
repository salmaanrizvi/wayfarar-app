//
//  NearbyStationTableViewCell.swift
//  wayfarer
//
//  Created by Salmaan on 3/15/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

struct StopData {
  let route: String
  let stopId: String
  let towards: String
  let arrivalTime: TimeInterval
  let formattedDate: String
}

class NearbyStationTableViewCell: UITableViewCell {
  static let reuseIdentifier = "blackNearbyStationCell";
  static let height: CGFloat = 200.0;
  static let fontName = "Helvetica Neue";
  static let largeSize: CGFloat = 40.0;
  static let smallSize: CGFloat = 16.0;

  
  @IBOutlet weak var colorStripe: UIView!
  @IBOutlet weak var stationLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!

  @IBOutlet weak var nbDirectionLabel: UILabel!
  @IBOutlet weak var nbTrainRouteLabel: UILabel!
  @IBOutlet weak var nbFirstArrival: UILabel!
  
  @IBOutlet weak var nbTrainRouteLabel_2: UILabel!
  @IBOutlet weak var nbTrainDirection_2: UILabel!
  @IBOutlet weak var nbSecondArrival: UILabel!
  
  @IBOutlet weak var sbDirectionLabel: UILabel!
  @IBOutlet weak var sbTrainRouteLabel: UILabel!
  @IBOutlet weak var sbFirstArrival: UILabel!
  
  @IBOutlet weak var sbTrainRotueLabel_2: UILabel!
  @IBOutlet weak var sbDirectionLabel_2: UILabel!
  @IBOutlet weak var sbSecondArrival: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib();
    self.roundRouteLabels();
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  func roundRouteLabels() {
    let routes: [UILabel] = [self.nbTrainRouteLabel, self.nbTrainRouteLabel_2, self.sbTrainRouteLabel, self.sbTrainRotueLabel_2];
    
    for routeLabel in routes {
      routeLabel.layer.cornerRadius = routeLabel.frame.height / 2;
      routeLabel.clipsToBounds = true;
    }
  }
  
  func configure(with station: Station, trains: [Train], userLoc: CLLocation?) {
    self.roundRouteLabels();

    let lineColors = colorMap[station.daytimeRoutes[0]];
    self.colorStripe.backgroundColor = lineColors?["line"];
    
//    self.nbTrainRouteLabel.backgroundColor = lineColors?["line"];
//    self.nbTrainRouteLabel.textColor = lineColors?["text"];
//
//    self.sbTrainRouteLabel.backgroundColor = lineColors?["line"];
//    self.sbTrainRouteLabel.textColor = lineColors?["text"];

    
    
    self.stationLabel.text = station.stopName.uppercased();

    if let userLoc = userLoc {
      self.distanceLabel.text = station.nearestEntrance(to: userLoc);
    }
    else { self.distanceLabel.text = "Calculating.." }
    
    let now = Date(timeIntervalSinceNow: 0).timeIntervalSince1970;
    let (northbound, southbound) = self.getArrivals(for: station, from: trains, filter: now)

    let defaultDate = self.getAttributedTextFor(string: "-- min");
    let defaultRoute = station.daytimeRoutes[0];
    
    if let nbStop = northbound.get(index: 0) {
      self.nbFirstArrival.attributedText = self.getAttributedTextFor(string: nbStop.formattedDate);
      self.nbDirectionLabel.text = "to \(nbStop.towards)".uppercased();
      self.nbTrainRouteLabel.text = nbStop.route;
      self.nbTrainRouteLabel.backgroundColor = colorMap[nbStop.route]?["line"]
      self.nbTrainRouteLabel.textColor = colorMap[nbStop.route]?["text"];
    }
    else {
      self.nbFirstArrival.attributedText =  defaultDate;
      self.nbTrainRouteLabel.text = defaultRoute;
      self.nbTrainRouteLabel.backgroundColor = lineColors?["line"];
      self.nbTrainRouteLabel.textColor = lineColors?["text"];
    }
    
    if let nbStop = northbound.get(index: 1) {
      self.nbSecondArrival.attributedText = self.getAttributedTextFor(string: nbStop.formattedDate);
      self.nbTrainDirection_2.text = "to \(nbStop.towards)".uppercased();
      self.nbTrainRouteLabel_2.text = nbStop.route;
      self.nbTrainRouteLabel_2.textColor = colorMap[nbStop.route]?["text"];
      self.nbTrainRouteLabel_2.backgroundColor = colorMap[nbStop.route]?["line"]
    }
    else {
      self.nbSecondArrival.attributedText = defaultDate;
      self.nbTrainRouteLabel_2.text = defaultRoute;
      self.nbTrainRouteLabel_2.textColor = lineColors?["text"];
      self.nbTrainRouteLabel_2.backgroundColor = lineColors?["line"];
    }

    if let sbStop = southbound.get(index: 0) {
      self.sbFirstArrival.attributedText = self.getAttributedTextFor(string: sbStop.formattedDate);
      self.sbDirectionLabel.text = "to \(sbStop.towards)".uppercased();
      self.sbTrainRouteLabel.text = sbStop.route;
      self.sbTrainRouteLabel.backgroundColor = colorMap[sbStop.route]?["line"]
      self.sbTrainRouteLabel.textColor = colorMap[sbStop.route]?["text"];
    }
    else {
      self.sbFirstArrival.attributedText = defaultDate
      self.sbTrainRouteLabel.text = defaultRoute;
      self.sbTrainRouteLabel.textColor = lineColors?["text"];
      self.sbTrainRouteLabel.backgroundColor = lineColors?["line"];
    }

    if let sbStop = southbound.get(index: 1) {
      self.sbSecondArrival.attributedText = self.getAttributedTextFor(string: sbStop.formattedDate);
      self.sbDirectionLabel_2.text = "to \(sbStop.towards)".uppercased()
      self.sbTrainRotueLabel_2.text = sbStop.route;
      self.sbTrainRotueLabel_2.backgroundColor = colorMap[sbStop.route]?["line"]
      self.sbTrainRotueLabel_2.textColor = colorMap[sbStop.route]?["text"];
    }
    else {
      self.sbSecondArrival.attributedText = defaultDate;
      self.sbTrainRotueLabel_2.text = defaultRoute;
      self.sbTrainRotueLabel_2.textColor = lineColors?["text"];
      self.sbTrainRotueLabel_2.backgroundColor = lineColors?["line"];
    }
    
    self.setNeedsDisplay();
  }
  
  func getArrivals(for station: Station, from trains: [Train], filter: TimeInterval) -> ([StopData], [StopData]) {
    var northbound: [StopData] = [];
    var southbound: [StopData] = [];
    
    for train in trains {
      let stopIdFilter = station.stopId + train.direction;
//      let filtered = train.stops.filter({
//        $0.stationId == stopIdFilter && $0.arrivalTime >= filter
//      });

      train.stops.forEach({
        if ($0.stationId == stopIdFilter && $0.arrivalTime >= filter) {
          let stopData = StopData(route: train.route, stopId: station.stopId, towards: train.towards, arrivalTime: $0.arrivalTime, formattedDate: $0.formattedDate)
          train.direction == "N" ? northbound.append(stopData) : southbound.append(stopData);
        }
      });
      
      northbound.sort(by: { $0.arrivalTime < $1.arrivalTime });
      southbound.sort(by: { $0.arrivalTime < $1.arrivalTime });
    }
    
    return (northbound, southbound);
  }

  func getOrderedArrivals(direction: String, _ trains: [Train], _ stopId: String, _ filter: TimeInterval) -> ([Stop], [String]) {
    
    var stops: [Stop] = [];
    let stopIdFilter = stopId + direction;
    var towards: [String] = [];
    
    trains.forEach { train in
      if (train.direction != direction) { return; }
      let filteredStops = train.stops.filter({ $0.stationId == stopIdFilter && $0.arrivalTime >= filter });
      stops.append(contentsOf: filteredStops);
      towards.append(train.towards);
    };
    
    stops.sort(by: { $0.arrivalTime < $1.arrivalTime });
    return (stops, towards);
  }
  
  func getAttributedTextFor(string: String) -> NSMutableAttributedString? {
    let str = NSString(string: string);
    let textRange = NSMakeRange(0, str.length);
    let attributedText = NSMutableAttributedString(string: string);
    
    str.enumerateSubstrings(in: textRange, options: [.reverse, .byWords], using: {
      (substr, substringRange, enclosingRange, _) in
      
      if substr != nil {
        if (substr!.lowercased() == "min" || substr!.lowercased() == "sec") {
          attributedText.addAttribute(.font, value: UIFont(name: NearbyStationTableViewCell.fontName, size: NearbyStationTableViewCell.smallSize)!, range: substringRange);
        }
        else {
          attributedText.addAttribute(.font, value: UIFont(name: NearbyStationTableViewCell.fontName, size: NearbyStationTableViewCell.smallSize)!, range: enclosingRange);
          
          attributedText.addAttribute(.font, value: UIFont(name: NearbyStationTableViewCell.fontName, size: NearbyStationTableViewCell.largeSize)!, range: substringRange);

        }
      }
    });
    
    return attributedText;
  }
}
