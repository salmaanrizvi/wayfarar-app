//
//  StationTableViewCell.swift
//  wayfarer
//
//  Created by Salmaan on 2/7/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import CoreLocation.CLLocation

class StationTableViewCell: UITableViewCell {
  static let reuseIdentifier = "nearbyStationCell";
  static let height: CGFloat = 225.0;

  @IBOutlet weak var containerView: UIView!

  @IBOutlet weak var daytimeRouteStack: UIStackView!
  @IBOutlet weak var daytimeRouteLabel: UILabel!
  @IBOutlet weak var daytimeRouteLabel2: UILabel!
  @IBOutlet weak var daytimeRouteLabel3: UILabel!
  @IBOutlet weak var daytimeRouteLabel4: UILabel!
  
  @IBOutlet weak var stationNameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  
  @IBOutlet weak var arrivalsStack: UIStackView!

  @IBOutlet weak var firstNorthArrival: UILabel!
  @IBOutlet weak var secondNorthArrival: UILabel!

  @IBOutlet weak var firstSouthArrival: UILabel!
  @IBOutlet weak var secondSouthArrival: UILabel!
  
  lazy var arrivals: [UILabel] = [self.firstNorthArrival, self.secondNorthArrival, self.firstSouthArrival, self.secondSouthArrival];
  
  override func awakeFromNib() {
    super.awakeFromNib();
    // Initialization code
    self.selectionStyle = .none;

    self.containerView.layer.cornerRadius = 15.0;
    self.daytimeRouteLabel.backgroundColor = UIColor.white;
    
    self.daytimeRouteStack.arrangedSubviews.forEach { subview in
      subview.clipsToBounds = true;
      subview.layer.cornerRadius = subview.frame.height / 2;
      subview.backgroundColor = .white;
    }
    
    self.daytimeRouteStack.spacing = (self.containerView.frame.height - 4 * self.daytimeRouteLabel.frame.height) / 4;
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated);
  }

  override func prepareForReuse() {
    self.daytimeRouteStack.arrangedSubviews.forEach { view in
      view.backgroundColor = .white;
    }
  }
  
  func configure(with station: Station, trains: [Train], userLoc: CLLocation?) {
    let lineColors = colorMap[station.daytimeRoutes[0]];
    self.containerView.backgroundColor = lineColors?["line"];
    self.setupDaytimeRoutes(for: station, color: lineColors?["text"]);
    self.stationNameLabel.text = station.stopName;
    if let userLoc = userLoc {
      self.distanceLabel.text = station.nearestEntrance(to: userLoc);
    }
    else { self.distanceLabel.text = "Updating.." }
    
    let now = Date(timeIntervalSinceNow: -60).timeIntervalSince1970;
    let (northbound, nbTowards) = self.getOrderedArrivals(direction: "N", trains, station.stopId, now);
    let (southbound, sbTowards) = self.getOrderedArrivals(direction: "S", trains, station.stopId, now);

    let defaultDate: String? = nil;

    if let nbStop = northbound.get(index: 0), let nbToward = nbTowards.get(index: 0) {
      self.firstNorthArrival.text = nbToward + " - " + nbStop.formattedDate
    }
    else { self.firstNorthArrival.text = defaultDate; }

    if let nbStop = northbound.get(index: 1), let nbToward = nbTowards.get(index: 1) {
      self.secondNorthArrival.text = nbToward + " - " + nbStop.formattedDate
    }
    else { self.secondNorthArrival.text = defaultDate; }

    if let sbStop = southbound.get(index: 0), let sbToward = sbTowards.get(index: 0) {
      self.firstSouthArrival.text = sbToward + " - " + sbStop.formattedDate
    }
    else { self.firstSouthArrival.text = defaultDate }

    if let sbStop = southbound.get(index: 1), let sbToward = sbTowards.get(index: 1) {
      self.secondSouthArrival.text = sbToward + " - " + sbStop.formattedDate
    }
    else { self.secondSouthArrival.text = defaultDate }
  }
  
  func getOrderedArrivals(direction: String, _ trains: [Train], _ stopId: String, _ filter: TimeInterval) -> ([Stop], [String]) {
    
    var stops: [Stop] = [];
    let stopIdFilter = stopId + direction;
    var towards: [String] = [];

    trains.forEach { train in
      if (train.direction != direction) { return; }
      let filteredStops = train.stops.filter({ $0.stationId == stopIdFilter && $0.arrivalTime >= filter });
      stops.append(contentsOf: filteredStops);
      towards.append("\(train.route) - \(train.towards)");
    };

    stops.sort(by: { $0.arrivalTime < $1.arrivalTime });
    return (stops, towards);
  }
  
  func setupDaytimeRoutes(for station: Station, color: UIColor?) {
    for i in 0 ..< station.daytimeRoutes.count {
      let label = self.daytimeRouteStack.arrangedSubviews[i] as! UILabel;
      label.text = station.daytimeRoutes[i];
      label.textColor = self.containerView.backgroundColor;
    }
    
    for i in 1 ..< self.daytimeRouteStack.arrangedSubviews.count {
      if i > station.daytimeRoutes.count - 1 {
        let label = self.daytimeRouteStack.arrangedSubviews[i] as! UILabel;
        label.backgroundColor = self.containerView.backgroundColor;
        label.textColor = UIColor.clear;
      }
    }
    
    self.stationNameLabel.textColor = color;
    self.distanceLabel.textColor = color;
    self.arrivalsStack.arrangedSubviews.forEach { (view) in
      (view as? UILabel)?.textColor = color;
    }
  }
}
