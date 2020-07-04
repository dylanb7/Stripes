//
//  Extensions.swift
//  Stripes
//
//  Created by Dylan Baker on 3/11/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit
import MapKit

extension Int32 {
  
  func toDate() -> Date {
    return Date(timeIntervalSince1970: TimeInterval(self))
  }
  
}

extension Date {
  
  func toTime() -> Int32 {
    return Int32(self.timeIntervalSince1970)
  }
  
  func cleanString(_ withTime : Bool) -> String {
    let calendar : Calendar = Calendar.current
    let month : Int = calendar.component(.month, from: self)
    let day : Int = calendar.component(.day, from: self)
    let year : Int = calendar.component(.year, from: self)
    let res : String = "\(month)/\(day)/\(year)"
    if withTime {
      let hour : Int = calendar.component(.hour, from: self)
      var vis : Int = hour > 12 ? hour-12 : hour
      vis = vis == 0 ? 12 : vis
      let suffix : String = hour >= 12 ? "PM" : "AM"
      let minute : Int = calendar.component(.minute, from: self)
      let mstring : String = minute < 10 ? "0\(minute)" : "\(minute)"
      return "\(res) at \(vis):\(mstring)\(suffix)"
    }
    return res
  }
  
}

extension UIFont {
    
  static func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
    let constrainingDimension = min(bounds.width, bounds.height)
    let properBounds = CGRect(origin: .zero, size: bounds.size)
    var attributes = additionalAttributes ?? [:]
        
    let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    var bestFontSize: CGFloat = constrainingDimension
        
    for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
      let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
      attributes[.font] = newFont
            
      let currentFrame = text.boundingRect(
        with: infiniteBounds,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: attributes,
        context: nil)
            
      if properBounds.contains(currentFrame) {
        bestFontSize = fontSize
        break
      }
    }
    return bestFontSize
    
  }
    
  static func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
    let bestSize = bestFittingFontSize(
      for: text,
      in: bounds,
      fontDescriptor: fontDescriptor,
      additionalAttributes: additionalAttributes)
    return UIFont(descriptor: fontDescriptor, size: bestSize)
  }
}

extension UILabel {
  
  func fitTextToBounds() {
    guard let text = self.text, let currentFont = self.font else { return }
  
    let bestFittingFont = UIFont.bestFittingFont(
      for: text,
      in: bounds,
      fontDescriptor:
      currentFont.fontDescriptor,
      additionalAttributes: basicStringAttributes)
    self.font = bestFittingFont
  }
    
  private var basicStringAttributes: [NSAttributedString.Key: Any] {
    var attribs = [NSAttributedString.Key: Any]()
        
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = self.textAlignment
    paragraphStyle.lineBreakMode = self.lineBreakMode
    attribs[.paragraphStyle] = paragraphStyle
        
    return attribs
  }
  
}

extension UIButton {
  
  func fitTextToBounds() {
    self.titleLabel?.minimumScaleFactor = 0.01
    self.titleLabel?.numberOfLines = 1
    self.titleLabel?.adjustsFontForContentSizeCategory = true
    self.titleLabel?.font = UIFont(name: (self.titleLabel?.font.fontName)!, size: 100)!
  }
  
}

extension UIView {
  
  func roundCorners(_ am : CGFloat) {
    self.layer.cornerRadius = am
    self.clipsToBounds = true
  }
  
  func allSubViews() -> [UIView]{
    var all = [UIView]()
    func getSubview(view: UIView) {
      all.append(view)
      guard view.subviews.count>0 else { return }
      view.subviews.forEach{ getSubview(view: $0) }
    }
    getSubview(view: self)
    all.remove(at: 0)
    return all
  }
  
  func removeAllSubviews() {
    self.allSubViews().forEach({sub in
      sub.removeFromSuperview()
    })
  }
  
  func fadeChildren(alpha : CGFloat) {
    self.allSubViews().forEach({ view in
      view.alpha = alpha
    })
  }
  
  static func getSeparator(width : Bool, withColor : UIColor) -> UIView {
    let separator = UIView()
    if width {
      separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
    } else {
      separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    separator.backgroundColor = withColor
    return separator
  }
  
}

extension UIViewController {
  
  func dismissChildViews() {
    for child in self.children {
      child.dismiss(animated: false, completion: nil)
    }
  }
  
}

extension CLLocation {
  
  func fetchCityAndCountry(completion: @escaping (_ city: String?,_ state: String?, _ country:  String?, _ error: Error?) -> ()) {
      CLGeocoder().reverseGeocodeLocation(self) {
        completion($0?.first?.locality, $0?.first?.administrativeArea, $0?.first?.country, $1)
          
      }
    }
  
}
