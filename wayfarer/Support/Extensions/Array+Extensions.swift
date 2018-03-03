//
//  Array+Extensions.swift
//  wayfarer
//
//  Created by Salmaan on 2/18/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation

extension Array {
  
  ///   Safely lookup an index that might be out of bounds, returning nil if it does not exist.
  ///   Parameter index: The index of the item in the array to return.
  public func get(index: Int) -> Element? {
    if 0 <= index && index < count {
      return self[index];
    } else {
      return nil;
    }
  }
}
