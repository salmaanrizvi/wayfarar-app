//
//  SettingsManager.swift
//  wayfarer
//
//  Created by Salmaan on 4/30/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation

enum SettingsKey: String {
  case searchDistance = "Search Distance"
  case units = "Units"
  
  static var keys: [SettingsKey] = [.searchDistance, .units];
}

class SettingsManager {
  static let `default` = SettingsManager();
  
  private var settings: [String: AnyObject];

  private init() {
    if let savedSettings = UserDefaults.settings?.dictionary(forKey: "settings") as [String: AnyObject]? {
      settings = savedSettings
      print("loaded settings from user defaults");
    }
    else {
      guard let path = Bundle.main.path(forResource: "DefaultSettings", ofType: "plist")
      else { fatalError("Could not load default settings.") };
      
      if let defaultSettings = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
        settings = defaultSettings;
        print("loaded settings from default settings plist");
      }
      else { fatalError("Could not get default settings from plist."); }
    }
    self.save();
  }
  
  public var count: Int { get { return self.settings.count; } }
  
  public func keys() -> [String] {
    return Array(self.settings.keys).sorted();
  }
  
  public func save() {
    UserDefaults.settings?.set(self.settings, forKey: "settings");
    UserDefaults.settings?.synchronize();
  }
  
  public func set(value: AnyObject, forKey key: SettingsKey) {
    self.settings.updateValue(value, forKey: key.rawValue);
    self.save();
  }
  
  public func value(forKey key: SettingsKey) -> AnyObject? {
    return self.settings[key.rawValue];
  }
  
  public func remove(forKey key: String) -> AnyObject? {
    let obj = self.settings.removeValue(forKey: key);
    self.save();
    return obj;
  }
}

extension UserDefaults {
  static let settings = UserDefaults(suiteName: "settings");
}
