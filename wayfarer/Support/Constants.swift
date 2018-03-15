//
//  Constants.swift
//  wayfarer
//
//  Created by Salmaan on 2/7/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import UIKit.UIColor
import CoreLocation.CLLocation

let _ace = ["text": .white, "line": UIColor(hexString: "#0039A6")];
let _bdfm = ["text": .white, "line": UIColor(hexString: "#FF6319")];
let _g = ["text": .white, "line": UIColor(hexString: "#6CBE45")];

let _jz = ["text": .white, "line": UIColor(hexString: "#996633")];
let _l = ["text": .white, "line": UIColor(hexString: "#A7A9AC")];
let _nqrw = ["text": .black, "line": UIColor(hexString: "#FCCC0A")];
let _s = ["text": .white, "line": UIColor(hexString: "#808183")];
let _123 = ["text": .white, "line": UIColor(hexString: "#EE352E")];
let _456 = ["text": .white, "line": UIColor(hexString: "#00933C")];
let _7 = ["text": .white, "line": UIColor(hexString: "#B933AD")];

let groupedLines = [_ace, _bdfm, _g, _l, _nqrw, _123, _456, _7];

public let colorMap: [String: [String: UIColor]] = [
  "A": _ace, "C": _ace, "E": _ace,
  "B": _bdfm, "D": _bdfm, "F": _bdfm, "M": _bdfm,
  "G": _g, "J": _jz, "Z": _jz, "L": _l,
  "N": _nqrw, "Q": _nqrw, "R": _nqrw, "W": _nqrw,
  "S": _s, "1": _123, "2": _123, "3": _123,
  "4": _456, "5": _456, "6": _456, "7": _7
];

let MINIMUM_ALTITUDE: CLLocationDistance = 100.0;
