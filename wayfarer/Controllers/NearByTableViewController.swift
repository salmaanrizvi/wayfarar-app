//
//  NearByTableViewController.swift
//  wayfarer
//
//  Created by Salmaan on 2/5/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import CoreLocation
import Pulley

class NearByTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  lazy var stationManager = StationManager.default;
  
  lazy var stations: [Station] = [];
  lazy var trains: [[Train]] = [];
  
  
  @IBOutlet weak var navigationBar: UINavigationBar!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad();
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view.backgroundColor = .clear;
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveScrollToNotification), name: .ScrollToStationNotification, object: nil);
    
    self.tableView.register(UINib(nibName: "NearbyStationTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: NearbyStationTableViewCell.reuseIdentifier);
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated);
    NotificationCenter.default.removeObserver(self);
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
//  @objc func refreshRequested(_ sender: UIRefreshControl) {
//    self.stationManager.requestNearbyStations();
//  }

  @objc func didReceiveScrollToNotification(_ notification: NSNotification) {
    guard let data = notification.object as? [String: Any],
          let stations = data["stations"] as? [Station],
          let trains = data["trains"] as? [[Train]]
    else { return; }

    self.stations = stations;
    self.trains = trains;
    self.tableView.reloadData(on: .main);
  }
  
  // MARK: - Table view data source
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1;
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.stations.count;
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: NearbyStationTableViewCell.reuseIdentifier, for: indexPath);
    
    guard let stationCell = cell as? NearbyStationTableViewCell,
          let station = self.stations.get(index: indexPath.row),
          let trains = self.trains.get(index: indexPath.row)
    else { return cell; }
    
    stationCell.configure(with: station, trains: trains, userLoc: self.stationManager.location);
    return stationCell;
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return NearbyStationTableViewCell.height;
  }
}

extension NearByTableViewController: StationManagerDelegate {
  func stationManager(_ manager: StationManager, updatedHeading heading: CLHeading, andCalculatedHeading calculated: CLLocationDirection?) {
    
  }
  
  func stationManager(_ manager: StationManager, didUpdateStations stations: [Station]?, withTrains trains: [[Train]]) {

    DispatchQueue.main.async {
      self.tableView.reloadData();
    }
  }
  
  func stationManager(_ manager: StationManager, didFailUpdateWithError error: Error) {
    // TBU -- show error to user?
  }
}

extension NearByTableViewController: PulleyDrawerViewControllerDelegate {
  func collapsedDrawerHeight() -> CGFloat {
    return 0;
  }
  
  func partialRevealDrawerHeight() -> CGFloat {
    return NearbyStationTableViewCell.height + 60;
  }
  
  func supportedDrawerPositions() -> [PulleyPosition] {
    return [.closed, .partiallyRevealed];
  }
}
