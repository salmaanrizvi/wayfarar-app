//
//  SettingsViewController.swift
//  wayfarer
//
//  Created by Salmaan on 4/14/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import Pulley

class SettingsViewController: UIViewController {
  static let reuseIdentifier = "settingsCell";
  
  @IBOutlet weak var tableView: UITableView!
  
  let keys = SettingsKey.keys;
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
  }
  
  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    let open: Bool = false;
    NotificationCenter.default.post(name: .SettingsNotification, object: open);
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1;
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return keys.count;
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SettingsViewController.reuseIdentifier, for: indexPath);
    
    let key = keys[indexPath.row];
    let value = SettingsManager.default.value(forKey: key);
    cell.textLabel?.text = key.rawValue;
    cell.detailTextLabel?.text = value != nil ? String(describing: value!) : "";
    return cell;
  }
}

extension SettingsViewController: PulleyDrawerViewControllerDelegate {
  func collapsedDrawerHeight() -> CGFloat {
    return 0;
  }
  
  func partialRevealDrawerHeight() -> CGFloat {
    return NearbyStationTableViewCell.height + 60;
  }
  
  func supportedDrawerPositions() -> [PulleyPosition] {
    return [.closed, .open];
  }
}
