//
//  PopDelegate.swift
//  Stripes
//
//  Created by Dylan Baker on 3/21/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import Foundation

protocol PopDelegate {
  
  func didDismiss(_ popUp : PopUp)
  
  func didLoad(_ popUp : PopUp)
  
}
