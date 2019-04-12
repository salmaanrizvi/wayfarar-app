//
//  PulleyContainerViewController.swift
//  wayfarer
//
//  Created by Salmaan on 3/4/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import Pulley

enum DrawerType: String {
  case settings = "SettingsViewController"
  case stations = "NearByTableViewController"
}

class PulleyContainerViewController: PulleyViewController {
  
  var currentDrawer: DrawerType = .stations;
  
  override func viewDidLoad() {
    super.viewDidLoad();
    
    self.backgroundDimmingOpacity = 0.0;
    self.initialDrawerPosition = .closed;
    self.setDrawerPosition(position: .closed);
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDrawerNotification), name: .DrawerNotification, object: nil);
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSettingsNotification), name: .SettingsNotification, object: nil)
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
      let position: PulleyPosition = notification.object != nil ? .partiallyRevealed : .closed;
      
      if notification.object != nil {
        self.setDrawer(to: .stations, completion: {
          NotificationCenter.default.post(name: .ScrollToStationNotification, object: notification.object);
          self.setDrawerPosition(position: position, animated: true)
        });
      }
      else { // close drawer notif
        self.setDrawerPosition(position: position, animated: true);
      }
    }
  }
  
  @objc func didReceiveSettingsNotification(_ notification: NSNotification) {
    if let open = notification.object as? Bool {
      DispatchQueue.main.async {
        let position: PulleyPosition = open ? .open : .closed;

        if open {
          self.setDrawer(to: .settings, completion: {
            self.setDrawerPosition(position: position, animated: !open);
          })
        }
        else { self.setDrawerPosition(position: position, animated: !open) }
      }
    }
  }
  
  func setDrawer(to drawerType: DrawerType, completion: @escaping () -> ()) {
    if drawerType == self.currentDrawer {
      return completion();
    }
    else {
      let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: drawerType.rawValue);
      
      self.currentDrawer = drawerType;
      self.setDrawerContentViewController(controller: vc, animated: false, completion: { finished in
        return completion();
      });
    }
  }
}
