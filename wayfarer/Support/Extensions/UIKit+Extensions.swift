//
//  UIKit+Extensions.swift
//  wayfarer
//
//  Created by Salmaan on 3/13/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func present(_ vc: UIViewController, animated: Bool = true, on thread: DispatchQueue = DispatchQueue.main, completion: (() -> Swift.Void)? = nil) {
    
    thread.async {
      self.present(vc, animated: animated, completion: completion);
    }
  }
}

extension UITableView {
  func reloadData(on thread: DispatchQueue) {
    thread.async { self.reloadData(); }
  }
}
