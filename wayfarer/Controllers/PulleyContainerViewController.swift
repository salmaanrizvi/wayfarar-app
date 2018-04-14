//
//  PulleyContainerViewController.swift
//  wayfarer
//
//  Created by Salmaan on 3/4/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import Pulley

class PulleyContainerViewController: PulleyViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad();
    
    self.initialDrawerPosition = .closed;
    self.setDrawerPosition(position: .closed);
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDrawerNotification), name: .DrawerNotification, object: nil);
  }
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated);
    NotificationCenter.default.removeObserver(self);
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func didReceiveDrawerNotification(_ notification: NSNotification) {
    DispatchQueue.main.async {
      if notification.object != nil {
        NotificationCenter.default.post(name: .ScrollToStationNotification, object: notification.object);
        self.setDrawerPosition(position: .partiallyRevealed, animated: true);
      }
      else { // close drawer notif
        self.setDrawerPosition(position: .closed, animated: true);
      }
    }
  }
}
