//
//  Sign.swift
//  wayfarer
//
//  Created by Salmaan on 2/18/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import Foundation
import ARKit
import ARCL
import CoreLocation.CLLocation

typealias BoundingBox = (min: SCNVector3, max: SCNVector3);

class StationNode: LocationAnnotationNode {

  static let size = CGSize(width: 15.0, height: 15.0);
  static let stationNameWidth: Float = 3.40;

  public var station: Station;
  
  public init(station: Station, userLoc: CLLocation) {
    self.station = station;
    let loc = self.station.entranceLoc(to: userLoc);
    super.init(location: loc);

    self.continuallyAdjustNodePositionWhenWithinRange = true;
    self.scaleRelativeToDistance = false;
    
    let scene = SCNScene(named: "art.scnassets/Station Coin.scn")!;
    let nodeArray = scene.rootNode.childNodes;
    self.update(station: station, userLoc: userLoc, nodes: nodeArray);
  
//    let rotate = SCNAction.repeatForever(SCNAction.rotateBy(x: 0.0, y: CGFloat.pi, z: 0, duration: 2.5))
//    self.annotationNode.runAction(rotate);

    self.addChildNode(annotationNode);
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(station: Station, userLoc: CLLocation, nodes: [SCNNode]? = nil) {
    guard let firstRoute = station.daytimeRoutes.get(index: 0) else { return; }

    self.station = station;
    let isNew = nodes != nil;
    let nodeArray = nodes ?? self.annotationNode.childNodes;
    var coinNode: SCNNode?

    for childNode in nodeArray {
      if childNode.name?.index(of: "Coin") != nil {
        coinNode = childNode;
        childNode.geometry?.firstMaterial?.diffuse.contents = colorMap[firstRoute]?["line"];
      }
      else if childNode.name?.index(of: "Letter") != nil {
        self.center(text: firstRoute, in: childNode);
      }
      else if childNode.name?.index(of: "Station_Name") != nil {
        self.center(text: station.stopName, in: childNode, withinBoundsOfNode: coinNode);
      }
      else if childNode.name?.index(of: "Distance") != nil {
        let text = self.station.nearestEntrance(to: userLoc);
        self.center(text: text, in: childNode);
      }
      
      if isNew { self.annotationNode.addChildNode(childNode as SCNNode) }
    }
  }
  
  func center(node: SCNNode, in boundingBox: BoundingBox?) {
    if let (min, max) = boundingBox {
      let dx = min.x + 0.5 * (max.x - min.x);
      let dy = min.y + 0.5 * (max.y - min.y);
      node.pivot = SCNMatrix4MakeTranslation(dx, dy, 0);
    }
  }
  
  func center(text: String, in node: SCNNode, withinBoundsOfNode boundingNode: SCNNode? = nil) {
    if let textGeometry = node.geometry as? SCNText {
      let origBound = textGeometry.boundingBox;

      textGeometry.string = text;
      textGeometry.isWrapped = true;
      textGeometry.truncationMode = kCATruncationEnd;

      let newBound = textGeometry.boundingBox;
      var dx = 0.5 * ((newBound.max.x - newBound.min.x) - (origBound.max.x - origBound.min.x));
      
      if let boundingNode = boundingNode {
        let currentBox = boundingNode.geometry!.boundingBox;
        let convertedBox: BoundingBox = (node.convertVector(currentBox.min, from: boundingNode), node.convertVector(currentBox.max, from: boundingNode));

        let width = sqrt(pow(convertedBox.max.x - convertedBox.min.x, 2)) - 50.0;
        let textWidth = sqrt(pow(newBound.max.x - newBound.min.x, 2));

        if (textWidth > width) {
          let scalar = width / textWidth;
          node.scale = SCNVector3Make(scalar * node.scale.x, node.scale.y, node.scale.z);
          dx -= ((textWidth - width) / 2);
        }
      }

      node.pivot = SCNMatrix4MakeTranslation(dx, 0, 0);
    }
  }
}
