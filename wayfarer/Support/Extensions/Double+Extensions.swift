//
//  Double+Extensions.swift
//  wayfarer
//
//  Created by Salmaan on 2/19/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation

extension Double {
  static let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"];

  func toCompassDirection() -> String {
    if self > 360.0 { return "Invalid"; }
    let normalized = (self / 45.0).rounded();
    return Double.directions[Int(normalized)];
  }
  
  func roundedToNearest(_ value: Double) -> Double {
    let nearest = (1.0 / value);
    return (self * nearest).rounded() / nearest;
  }
}
