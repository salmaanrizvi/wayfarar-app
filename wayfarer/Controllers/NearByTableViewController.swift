//
//  NearByTableViewController.swift
//  wayfarer
//
//  Created by Salmaan on 2/5/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import CoreLocation

class NearByTableViewController: UITableViewController {
  lazy var stationManager = StationManager();
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: #selector(refreshRequested), for: .valueChanged);
    
    stationManager.delegate = self;
    stationManager.enableLocationServices();
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func refreshRequested(_ sender: UIRefreshControl) {
    self.stationManager.requestNearbyStations();
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    guard self.stationManager.nearbyTransit != nil else { return 0; }
    return 1;
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let nearbyTransit = self.stationManager.nearbyTransit else { return 0; }
    return nearbyTransit.stations.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: StationTableViewCell.reuseIdentifier, for: indexPath);

    guard let stationCell = cell as? StationTableViewCell,
          let station = self.stationManager.nearbyTransit?.stations.get(index: indexPath.row),
          let trains = self.stationManager.trains.get(index: indexPath.row)
    else { return cell; }
    
    stationCell.configure(with: station, trains: trains, userLoc: self.stationManager.location);
    return stationCell;
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return StationTableViewCell.height;
  }
}

extension NearByTableViewController: StationManagerDelegate {
  func stationManager(_ manager: StationManager, updatedHeading heading: CLHeading, andCalculatedHeading calculated: CLLocationDirection?) {
    
  }
  
  func stationManager(_ manager: StationManager, didUpdateStations stations: [Station]?, withTrains trains: [[Train]]) {

    DispatchQueue.main.async {
      self.refreshControl?.endRefreshing();
      self.tableView.reloadData();
    }
  }
  
  func stationManager(_ manager: StationManager, didFailUpdateWithError error: Error) {
    // TBU -- show error to user?
  }
}
