//
//  Colors.swift
//  Stripes
//
//  Created by Dylan Baker on 3/9/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

enum Colors {
  case Header
  case Background
  case Button
  case Text
  case HeaderText
  
  func get()->UIColor{
    switch self {
      case .Header:
        return UIColor(red: CGFloat(252/255.0), green: CGFloat(175/255.0), blue: CGFloat(88/255.0), alpha: 1)
      case .Button:
        return UIColor(red: CGFloat(0/255.0), green: CGFloat(71/255.0), blue: CGFloat(119/255.0), alpha: 1)
      case .Text:
        return UIColor(red: CGFloat(255/255.0), green: CGFloat(255/255.0), blue: CGFloat(255/255.0), alpha: 1)
      case .Background:
        return UIColor(red: CGFloat(252/255.0), green: CGFloat(229/255.0), blue: CGFloat(199/255.0), alpha: 1)
      case .HeaderText:
        return UIColor(red: CGFloat(232/255.0), green: CGFloat(128/255.0), blue: CGFloat(60/255.0), alpha: 1)
    }
  }
  
}

enum scrollColors {
  case first
  case second
  case third
  case fourth
  
  func get()->UIColor{
    switch self {
      case .first: return UIColor(red: CGFloat(89/255.0), green: CGFloat(139/255.0), blue: CGFloat(175/255.0), alpha: 1)
      case .second: return UIColor(red: CGFloat(15/255.0), green: CGFloat(82/255.0), blue: CGFloat(186/255.0), alpha: 0.8)
      case .third: return UIColor(red: CGFloat(0/255.0), green: CGFloat(49/255.0), blue: CGFloat(81/255.0), alpha: 1)
      case .fourth: return UIColor(red: CGFloat(114/255.0), green: CGFloat(133/255.0), blue: CGFloat(165/255.0), alpha: 1)
    }
  }
  
}

struct typeColors {
  
  var data : symptomType?
  
  var event : eventType?
  
  func get() -> UIColor {
    guard let type = data else {
      switch event! {
        case .dietaryChange: return scrollColors.first.get()
        case .moved: return scrollColors.second.get()
        case .psychiatricHospitalization: return scrollColors.third.get()
        case .medicalIntervention: return scrollColors.fourth.get()
      }
    }
    switch type {
      case .BM: return scrollColors.first.get()
      case .OTHER: return scrollColors.second.get()
      case .PAIN: return scrollColors.third.get()
      case .REFLUX: return scrollColors.fourth.get()
    }
  }
  
}
