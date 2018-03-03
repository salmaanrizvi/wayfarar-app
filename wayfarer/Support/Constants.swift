//
//  Constants.swift
//  wayfarer
//
//  Created by Salmaan on 2/7/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import UIKit.UIColor

fileprivate let _ace = ["text": .white, "line": UIColor(hexString: "#0039A6")];
fileprivate let _bdfm = ["text": .white, "line": UIColor(hexString: "#FF6319")];
fileprivate let _g = ["text": .white, "line": UIColor(hexString: "#6CBE45")];

fileprivate let _jz = ["text": .white, "line": UIColor(hexString: "#996633")];
fileprivate let _l = ["text": .white, "line": UIColor(hexString: "#A7A9AC")];
fileprivate let _nqrw = ["text": .black, "line": UIColor(hexString: "#FCCC0A")];
fileprivate let _s = ["text": .white, "line": UIColor(hexString: "#808183")];
fileprivate let _123 = ["text": .white, "line": UIColor(hexString: "#EE352E")];
fileprivate let _456 = ["text": .white, "line": UIColor(hexString: "#00933C")];
fileprivate let _7 = ["text": .white, "line": UIColor(hexString: "#B933AD")];

public let colorMap: [String: [String: UIColor]] = [
  "A": _ace, "C": _ace, "E": _ace,
  "B": _bdfm, "D": _bdfm, "F": _bdfm, "M": _bdfm,
  "G": _g, "J": _jz, "Z": _jz, "L": _l,
  "N": _nqrw, "Q": _nqrw, "R": _nqrw, "W": _nqrw,
  "S": _s, "1": _123, "2": _123, "3": _123,
  "4": _456, "5": _456, "6": _456, "7": _7
];


