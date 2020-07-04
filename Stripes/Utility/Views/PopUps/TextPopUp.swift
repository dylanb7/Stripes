//
//  TextPopup.swift
//  Stripes
//
//  Created by Dylan Baker on 3/19/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import Foundation

import UIKit

class TextPopUp : PopUp, UITextFieldDelegate {
  
  private let inputHeaders: [String]!
  
  private var fields : [UITextField] = []
  
  private let parseFunction: (([String])->Void)?
  
  private lazy var scrollView : SwipeableScrollView = {
    let scroll : SwipeableScrollView = SwipeableScrollView(frame: CGRect.zero)
    scroll.showsVerticalScrollIndicator = true
    scroll.translatesAutoresizingMaskIntoConstraints = false
    return scroll
  }()
  
  private lazy var okButton : UIButton = {
    let button : UIButton = UIButton()
    button.backgroundColor = Colors.Background.get()
    button.setTitleColor(Colors.HeaderText.get(), for: .normal)
    button.titleLabel?.font = UIFont(name: "HiraginoSans-W3", size: 30)!
    button.setTitle("Done", for: .normal)
    button.layer.borderWidth = 3.0
    button.roundCorners(30)
    button.layer.borderColor = Colors.Button.get().cgColor
    button.addTarget(self, action: #selector(TextPopUp.okAction), for: .touchUpInside)
    button.layer.maskedCorners = [.layerMinXMaxYCorner]
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private lazy var cancelButton : UIButton = {
    let button : UIButton = UIButton()
    button.backgroundColor = Colors.Background.get()
    button.setTitleColor(Colors.HeaderText.get(), for: .normal)
    button.titleLabel?.font = UIFont(name: "HiraginoSans-W3", size: 30)!
    button.setTitle("Cancel", for: .normal)
    button.layer.borderWidth = 3.0
    button.roundCorners(30)
    button.layer.borderColor = Colors.Button.get().cgColor
    button.addTarget(self, action: #selector(TextPopUp.cancelAction), for: .touchUpInside)
    button.layer.maskedCorners = [.layerMaxXMaxYCorner]
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  init(_ parent: UIViewController, _ header: String, _ inputHeaders: [String], _ popDelegate : PopDelegate?, _ parseFunction: ((_ res: [String])->Void)?) {
    self.parseFunction = parseFunction
    self.inputHeaders = inputHeaders
    super.init(parent, header, popDelegate)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addButtons()
    self.addViews()
    self.popDelegate?.didLoad(self)
  }
  
  private func addButtons(){
    self.view.addSubview(okButton)
    
    NSLayoutConstraint.activate([
      okButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      okButton.trailingAnchor.constraint(equalTo: self.view.centerXAnchor),
      okButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      okButton.heightAnchor.constraint(equalToConstant: self.buttonHeightConstant)
    ])
    
    
    self.view.addSubview(cancelButton)
    
    NSLayoutConstraint.activate([
      cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      cancelButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      cancelButton.leadingAnchor.constraint(equalTo: self.view.centerXAnchor),
      cancelButton.heightAnchor.constraint(equalToConstant: self.buttonHeightConstant)
    ])
  }
  
  private func addViews() {
    self.view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      scrollView.widthAnchor.constraint(equalToConstant: self.viewWidth),
      scrollView.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -spacing/2)
    ])
    
    var topAnchor = scrollView.topAnchor
    
    let attributes = [
      NSAttributedString.Key.foregroundColor : UIColor.gray
    ]
    
    for name in inputHeaders {
      let field : UITextField = UITextField(frame: CGRect.zero)
      field.delegate = self
      field.backgroundColor = Colors.Text.get()
      field.textAlignment = .center
      field.translatesAutoresizingMaskIntoConstraints = false
      field.textColor = UIColor.black
      field.attributedPlaceholder = NSAttributedString(string: name, attributes: attributes)
      field.roundCorners(10)
      field.layer.borderColor = Colors.Button.get().cgColor
      field.layer.borderWidth = 2.0
      fields.append(field)
      scrollView.addSubview(field)
      
      NSLayoutConstraint.activate([
        field.topAnchor.constraint(equalTo: topAnchor, constant: self.spacing/2),
        field.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        field.widthAnchor.constraint(equalToConstant: self.viewWidth*0.9),
        field.heightAnchor.constraint(equalToConstant: self.spacing*2)
      ])
      
      field.placeholder = name
      topAnchor = field.bottomAnchor
      
    }
    
    scrollView.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
  }
  
  @objc private func okAction(){
    guard parseFunction != nil else{
      self.dismissPopup(true){}
      return
    }
    var res : [String] = []
    for field in fields {
      if let text = field.text {
        res.append(text)
      }
    }
    self.dismissPopup(true) {
      self.parseFunction!(res)
    }
  }
  
  @objc private func cancelAction(){
    self.dismissPopup(true){}
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
