//
//  SwipeableScrollView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/4/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit
class SwipeableScrollView: UIScrollView {
  
  override func touchesShouldCancel(in view: UIView) -> Bool {
    if view is UIButton || view is UILabel || view is UITextField {
      return true
    }
    
    return super.touchesShouldCancel(in: view)
  }
  
}
