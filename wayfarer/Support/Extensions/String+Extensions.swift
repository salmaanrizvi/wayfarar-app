//
//  Extensions.swift
//  wayfarer
//
//  Created by Salmaan on 2/7/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation

extension String {
  func index(of string: String, options: CompareOptions = .literal) -> Index? {
    return range(of: string, options: options)?.lowerBound
  }
  func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
    return range(of: string, options: options)?.upperBound
  }
  func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
    var result: [Index] = []
    var start = startIndex
    while let range = range(of: string, options: options, range: start..<endIndex) {
      result.append(range.lowerBound)
      start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
    }
    return result
  }
  func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
    var result: [Range<Index>] = []
    var start = startIndex
    while let range = range(of: string, options: options, range: start..<endIndex) {
      result.append(range)
      start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
    }
    return result
  }
}

