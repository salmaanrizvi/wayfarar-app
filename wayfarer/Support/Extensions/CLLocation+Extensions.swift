//
//  CLLocation+Extension.swift
//  wayfarer
//
//  Created by Salmaan on 2/18/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import CoreLocation.CLLocation
import MapKit

extension CLLocation {
  func distance(from: CLLocation, roundedTo value: Double) -> CLLocationDistance {
    let distance = self.distance(from: from);
    let nearest = (1.0 / value);
    return round(distance * nearest) / nearest;
  }
  
  static func headingFrom(source: CLLocation, to destination: CLLocation) -> CLLocationDirection {
    let sourcePoint = MKMapPointForCoordinate(source.coordinate);
    let destinationPoint = MKMapPointForCoordinate(destination.coordinate);
    let x = destinationPoint.x - sourcePoint.x
    let y = destinationPoint.y - sourcePoint.y
      
    return (atan2(y, x).radiansToDegrees).truncatingRemainder(dividingBy: 360) + 90.0;
  }
}

//extension CLLocationCoordinate2D {
//  var latRadians: Double { get { return self.latitude * .pi / 180; } }
//  var longRadians: Double { get { return self.longitude * .pi / 180; } }
//
//  func distance(to b: CLLocationCoordinate2D, roundedTo value: Double) -> Double {
//    let R = Double(6371 * pow(10.0, 3.0));
//    let phiA = self.latRadians;
//    let phiB = b.latRadians;
//    let phiDelta = phiB - phiA;
//    let gammaDelta = (b.longRadians - self.longRadians);
//
//    let alpha = sin(phiDelta / 2) * sin(phiDelta / 2)
//      + cos(phiA) * cos(phiB)
//      * sin(gammaDelta / 2) * sin(gammaDelta / 2);
//    let beta = 2 * atan2(sqrt(alpha), sqrt(1 - alpha))
//
//    if value == 0 { return R * beta; }
//    let nearest = (1.0 / value);
//    return round(R * beta * nearest) / nearest;
//  }
//}
