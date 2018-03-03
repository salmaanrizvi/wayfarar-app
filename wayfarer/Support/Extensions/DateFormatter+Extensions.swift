//
//  DateFormatter+Extensions.swift
//  wayfarer
//
//  Created by Salmaan on 2/18/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation

extension DateFormatter {
  static func parseTime(_ time: TimeInterval) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH mm";
    dateFormatter.timeStyle = .short;
    dateFormatter.dateStyle = .none;
    return dateFormatter.string(from: Date(timeIntervalSince1970: time));
  }
}
