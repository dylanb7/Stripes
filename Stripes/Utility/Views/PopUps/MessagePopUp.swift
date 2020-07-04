//
//  MessagePopUp.swift
//  Stripes
//
//  Created by Dylan Baker on 5/3/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class MessagePopUp: PopUp {
  
  private let message: String!
  
  private lazy var okButton: UIButton = {
    [unowned self] in
    let button : UIButton = UIButton(type: .custom)
    button.backgroundColor = Colors.Background.get()
    button.titleLabel?.font = UIFont(name: "HiraginoSans-W3", size: 30)!
    button.setTitleColor(Colors.HeaderText.get(), for: .normal)
    button.layer.borderWidth = 3.0
    button.roundCorners(30)
    button.layer.borderColor = Colors.Button.get().cgColor
    button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private lazy var messageLabel: UILabel = {
    [unowned self] in
    let message : UILabel = UILabel(frame: CGRect.zero)
    message.textAlignment = .center
    message.font = UIFont(name: "HiraginoSans-W3", size: 20)!
    message.text = self.message
    message.numberOfLines = -1
    message.textColor = Colors.HeaderText.get()
    message.translatesAutoresizingMaskIntoConstraints = false
    return message
  }()
  
  init(_ parentView : UIViewController, _ header: String, _ message: String, _ popDelegate : PopDelegate?) {
    self.message = message
    super.init(parentView, header, popDelegate)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addOkButton()
    self.addTitleAndMessage()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  func addOkButton() {
    self.view.addSubview(okButton)
    
    NSLayoutConstraint.activate([
      okButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      okButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      okButton.widthAnchor.constraint(equalToConstant: self.popSize!.width),
      okButton.heightAnchor.constraint(equalToConstant: self.buttonHeightConstant)
    ])
    
    okButton.setTitle("Done", for: .normal)
    okButton.addTarget(self, action: #selector(okAction(_:)), for: .touchUpInside)
  }
  
  func addTitleAndMessage() {
    let viewWidth : CGFloat = self.popSize!.width * 0.8
    
    self.view.addSubview(messageLabel)
    
    NSLayoutConstraint.activate([
      messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -spacing*1.5),
      messageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      messageLabel.widthAnchor.constraint(equalToConstant: viewWidth),
      messageLabel.bottomAnchor.constraint(equalTo: self.okButton.topAnchor)
    ])
  
  }
  
  
  
  @objc func okAction(_ sender : Any?){
    self.dismissPopup(true){}
  }
  
}
