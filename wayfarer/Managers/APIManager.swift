//
//  APIManager.swift
//  wayfarer
//
//  Created by Salmaan on 2/5/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import CoreLocation

public enum URLParameterEncoding {
  case JSON
  case URL
  case BODY
}

public class APIManager {
  
  public static let shared = APIManager();
  private let baseUrl = "http://35.196.99.29:8000/api";
  
  private init() {}
  
  func getNearbyTrains(_ coordinate: CLLocationCoordinate2D, completion: @escaping (_ error: Error?, _ response: NearbyTransit?) -> ()) {
    
    let maxDist = SettingsManager.default.value(forKey: .searchDistance) as! Int;
    print("max distance is.... \(maxDist)");
    self.get(path: "/location?lat=\(coordinate.latitude)&long=\(coordinate.longitude)&maxDistance=\(maxDist)") {
      (err, response) in
        if let e = err { return completion(e, nil) }
        guard let response = response else { return completion(nil, nil); }
        let decoder = JSONDecoder();
        do {
          let nearbyTransit = try decoder.decode(NearbyTransit.self, from: response)
          return completion(nil, nearbyTransit);
        }
        catch {
          print("failed to decode station data");
          return completion(error, nil);
        }
    }
  }
}

extension APIManager {
  
  public func get(path: String, completion: @escaping (_ error: Error?, _ response: Data?) -> ()) {
    let request = self.clientURLRequest(path: path);
    self.dataTask(request: request, method: "GET", completion: completion);
  }
  
  public func clientURLRequest(path: String) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(url: URL(string: self.baseUrl + path)!);
    
    // Set Authorization if required
    //        if authorization != "" {
    //            request?.addValue(authorization, forHTTPHeaderField: "Authorization")
    //        }
    
    return request
  }
  private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ error: Error? , _ response: Data?) -> ()) {
    
    request.httpMethod = method
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    request.timeoutInterval = 10.0;
    
    var profiler = Profiler();
    profiler.profile(key: "dataTask");
    let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
      profiler.profile(key: "dataTask");
      if let error = error { return completion(error, nil) }
      else if let data = data {
        
        //        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let httpResponse = response as? HTTPURLResponse else { return completion(NSError(), nil) }
        if httpResponse.statusCode > 299 {
          print("Response falls outside 200 range: ", httpResponse.statusCode);
          let error = NSError(domain: "Bad status code", code: httpResponse.statusCode);
          return completion(error, nil);
        }
        
        return completion(nil, data)
      }
    }
    
    dataTask.resume();
  }
}
