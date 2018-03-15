//
//  Profiler.swift
//  wayfarer
//
//  Created by Salmaan on 2/10/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation

struct Profiler {
  var profiles: [String: TimeInterval] = [:];
  
  mutating func profile(key: String) {
    if let time = self.profiles[key] {
      let elapsedTime = round((Date(timeIntervalSinceNow: 0).timeIntervalSince1970 - time) * 1000.0);
      print("\(key) took \(elapsedTime)ms");
      self.profiles.removeValue(forKey: key);
    }
    else {
      self.profiles.updateValue(Date(timeIntervalSinceNow: 0).timeIntervalSince1970, forKey: key);
    }
  }
}
