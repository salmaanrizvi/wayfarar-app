//
//  NearbyStationTableViewCell.swift
//  wayfarer
//
//  Created by Salmaan on 3/15/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

class NearbyStationTableViewCell: UITableViewCell {
  static let reuseIdentifier = "blackNearbyStationCell";
  static let height: CGFloat = 200.0;
  
  @IBOutlet weak var colorStripe: UIView!
  @IBOutlet weak var stationLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!

  @IBOutlet weak var nbDirectionLabel: UILabel!
  @IBOutlet weak var nbTrainRouteLabel: UILabel!
  @IBOutlet weak var nbFirstArrival: UILabel!
  @IBOutlet weak var nbSecondArrival: UILabel!
  
  @IBOutlet weak var sbDirectionLabel: UILabel!
  @IBOutlet weak var sbTrainRouteLabel: UILabel!
  @IBOutlet weak var sbFirstArrival: UILabel!
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
    self.nbTrainRouteLabel.layer.cornerRadius = self.nbTrainRouteLabel.frame.height / 2;
    self.nbTrainRouteLabel.clipsToBounds = true;
    self.sbTrainRouteLabel.layer.cornerRadius = self.sbTrainRouteLabel.frame.height / 2;
    self.sbTrainRouteLabel.clipsToBounds = true;
  }
  
  func configure(with station: Station, trains: [Train], userLoc: CLLocation?) {
    let lineColors = colorMap[station.daytimeRoutes[0]];
    
    self.colorStripe.backgroundColor = lineColors?["line"];
    
    self.nbTrainRouteLabel.backgroundColor = lineColors?["line"];
    self.nbTrainRouteLabel.textColor = lineColors?["text"];
    
    self.sbTrainRouteLabel.backgroundColor = lineColors?["line"];
    self.sbTrainRouteLabel.textColor = lineColors?["text"];
    
    let route = station.daytimeRoutes.get(index: 0) ?? "";
    self.nbTrainRouteLabel.text = route;
    self.sbTrainRouteLabel.text = route;
    self.roundRouteLabels();
    
    self.stationLabel.text = station.stopName.uppercased();

    if let userLoc = userLoc {
      self.distanceLabel.text = station.nearestEntrance(to: userLoc);
    }
    else { self.distanceLabel.text = "Calculating.." }
    
    let now = Date(timeIntervalSinceNow: 0).timeIntervalSince1970;
    let (northbound, nbTowards) = self.getOrderedArrivals(direction: "N", trains, station.stopId, now);
    let (southbound, sbTowards) = self.getOrderedArrivals(direction: "S", trains, station.stopId, now);
    
    let defaultDate = self.getAttributedTextFor(string: "-- min");
    
    if let nbStop = northbound.get(index: 0), let nbToward = nbTowards.get(index: 0) {
      self.nbFirstArrival.attributedText = self.getAttributedTextFor(string: nbStop.formattedDate);
      self.nbDirectionLabel.text = "to \(nbToward)".uppercased();
    }
    else { self.nbFirstArrival.attributedText =  defaultDate; }
    
    if let nbStop = northbound.get(index: 1) {
      self.nbSecondArrival.attributedText = self.getAttributedTextFor(string: nbStop.formattedDate);
    }
    else { self.nbSecondArrival.attributedText = defaultDate; }

    if let sbStop = southbound.get(index: 0), let sbToward = sbTowards.get(index: 0) {
      self.sbFirstArrival.attributedText = self.getAttributedTextFor(string: sbStop.formattedDate);
      self.sbDirectionLabel.text = "to \(sbToward)".uppercased();
    }
    else { self.sbFirstArrival.attributedText = defaultDate }

    if let sbStop = southbound.get(index: 1) {
      self.sbSecondArrival.attributedText = self.getAttributedTextFor(string: sbStop.formattedDate);

    }
    else { self.sbSecondArrival.attributedText = defaultDate }
  }
  
  func getOrderedArrivals(direction: String, _ trains: [Train], _ stopId: String, _ filter: TimeInterval) -> ([Stop], [String]) {
    
    var stops: [Stop] = [];
    let stopIdFilter = stopId + direction;
    var towards: [String] = [];
    
    trains.forEach { train in
      if (train.direction != direction) { return; }
      let filteredStops = train.stops.filter({ $0.stationId == stopIdFilter && $0.arrivalTime >= filter });
      stops.append(contentsOf: filteredStops);
      towards.append("\(train.towards)");
    };
    
    stops.sort(by: { $0.arrivalTime < $1.arrivalTime });
    return (stops, towards);
  }
  
  func getAttributedTextFor(string: String) -> NSMutableAttributedString? {
    let str = NSString(string: string);
    let textRange = NSMakeRange(0, str.length);
    let attributedText = NSMutableAttributedString(string: string);
    
    let fontName = "Helvetica Neue";
    let largeSize: CGFloat = 40.0;
    let smallSize: CGFloat = 16.0;

    str.enumerateSubstrings(in: textRange, options: [.reverse, .byWords], using: {
      (substr, substringRange, enclosingRange, _) in
      
      if substr != nil {
        if (substr!.lowercased() == "min" || substr!.lowercased() == "sec") {
          attributedText.addAttribute(.font, value: UIFont(name: fontName, size: smallSize)!, range: substringRange);
        }
        else {
            attributedText.addAttribute(.font, value: UIFont(name: fontName, size: smallSize)!, range: enclosingRange);
          attributedText.addAttribute(.font, value: UIFont(name: fontName, size: largeSize)!, range: substringRange);

        }
      }
    });
    
    return attributedText;
  }
}
