//
//  EditView.swift
//  Stripes
//
//  Created by Dylan Baker on 3/19/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class EditView : UIViewController {
  
  private let current : User!
  
  private let instance : Store = Store.instance
  
  private let spacing : CGFloat = StripesView.spacing
  
  init(_ current : User) {
    self.current = current
    super.init(nibName: nil, bundle: nil)
  }
  
  private func addInputs() {
    
    let stack : UIStackView = UIStackView()
    
    
    
    self.view.addSubview(stack)
    
    let topConstraint : NSLayoutYAxisAnchor = (self.navigationController?.navigationBar.bottomAnchor)!
    stack.topAnchor.constraint(equalTo: topConstraint, constant: spacing).isActive = true
    stack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -spacing).isActive = true
    stack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
