//
//  Representable.swift
//  Stripes
//
//  Created by Dylan Baker on 3/12/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class Representable : UIView {
  
  private var clickAction : ((_ ob : Stamped)->Void)?
  
  private var represented : Stamped?
  
  private init(_ frame: CGRect, _ color : UIColor, _ displayed : [String]) {
    super.init(frame: frame)
    self.backgroundColor = color
    self.addLabels(displayed, frame.height*0.05)
  }
  
  convenience init(_ frame : CGRect, _ data : UserData) {
    let vals : [String] = [data.time.toDate().cleanString(true), data.type]
    self.init(frame, Colors.HeaderText.get(), vals)
    self.represented = data
  }
  
  convenience init(frame: CGRect, event : Event) {
    let vals : [String] = [event.time.toDate().cleanString(true), event.type]+event.desc
    self.init(frame, Colors.Button.get(), vals)
    self.represented = event
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addClickAction(_ method : @escaping (Stamped)->Void){
    self.clickAction = method
  }
  
  private func addLabels(_ labels : [String], _ spacing : CGFloat) {
    let count : CGFloat = CGFloat(labels.count)
    let height : CGFloat = (frame.height-(spacing * (count+1)))/count
    var currentY : CGFloat = spacing
    for text in labels {
      let labelFrame : CGRect = CGRect(
        x: spacing,
        y: currentY,
        width: self.frame.width-(spacing*2),
        height: height
      )
      let label : UILabel = UILabel(frame: labelFrame)
      label.textAlignment = .center
      label.text = text
      label.textColor = Colors.Text.get()
      label.fitTextToBounds()
      self.addSubview(label)
      currentY+=(height+spacing)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let action = self.clickAction else { return }
    action(represented!)
  }
  
}
