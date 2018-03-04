//
//  ARTLoaderView.swift
//  wayfarer
//
//  Created by Salmaan on 3/3/18.
//  Copyright © 2018 Salmaan Rizvi. All rights reserved.
//

import UIKit
import MKRingProgressView
import LiquidLoader

class ARTLoaderView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame);
    self.isHidden = true;
    self.alpha = 0.0;

    let blurView = UIVisualEffectView(frame: frame);
    let blurEffect = UIBlurEffect(style: .regular);
    blurView.effect = blurEffect;
    blurView.translatesAutoresizingMaskIntoConstraints = false;
    self.addSubview(blurView);
    blurView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
    blurView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
    blurView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true;
    blurView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true;
    
    
    let loaderFrame = CGRect(origin: .zero, size: CGSize(width: 150.0, height: 150.0));
    let effect = Effect.growCircle(.black, 8, 3.0, .white);
    let loader = LiquidLoader(frame: loaderFrame, effect: effect);

    blurView.contentView.addSubview(loader);
    loader.translatesAutoresizingMaskIntoConstraints = false;
    loader.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
    loader.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
    loader.widthAnchor.constraint(equalToConstant: 150).isActive = true;
    loader.heightAnchor.constraint(equalToConstant: 150).isActive = true;
    self.setNeedsLayout();
  }
  
  func show(_ _in: TimeInterval = 0.5) {
    DispatchQueue.main.async {
      self.superview?.bringSubview(toFront: self);
      self.isHidden = false;
      
      UIView.animate(withDuration: _in) {
        self.alpha = 1.0;
      }
    }
  }
  
  func hide(_ _in: TimeInterval = 0.5) {
    DispatchQueue.main.async {
      UIView.animate(withDuration: _in, animations: {
        self.alpha = 0.0;
      }) { _ in
        self.superview?.sendSubview(toBack: self);
        self.isHidden = true;
      };
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("Not supported.");
  }
}
