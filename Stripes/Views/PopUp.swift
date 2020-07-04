//
//  PopUp.swift
//  Stripes
//
//  Created by Dylan Baker on 3/9/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class PopUp : UIViewController, UITextFieldDelegate {
  
  private let parentView : UIViewController!
  
  private let popView : UIView!
  
  private var fields : [UITextField] = []
  
  private let size : CGSize = UIScreen.main.bounds.size
  
  private var currentY : CGFloat!
  
  private let header: String!
  
  private let message: String!
  
  private let inputHeaders: [String]!
  
  private let parseFunction: (([String])->Void)?
  
  init(_ parent: UIViewController, _ header: String, _ message: String, _ inputHeaders: [String], _ parseFunction: ((_ res: [String])->Void)?) {
    self.header = header
    self.message = message
    self.parentView = parent
    self.parseFunction = parseFunction
    self.inputHeaders = inputHeaders
    let w : CGFloat = self.size.width * 0.8
    let h : CGFloat = self.size.height * 0.4
    self.currentY = h*0.15
    self.popView = UIView(frame: CGRect(x: (self.size.width - w)/2, y: (self.size.height - h)/2, width: w, height: h))
    super.init(nibName: nil, bundle: nil)
    self.view.addSubview(popView)
    self.modalPresentationStyle = .overCurrentContext
    
  }
  
  override func loadView() {
    super.loadView()
    self.view.backgroundColor = UIColor.clear
    self.view.translatesAutoresizingMaskIntoConstraints = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.popView.backgroundColor = Colors.Background.get()
    self.addTitleAndMessage(header, message)
    self.addButtons()
    self.addFields()
    self.popView.layer.cornerRadius = 30
    self.popView.layer.masksToBounds = false
    self.popView.layer.borderWidth = 5.0
    self.popView.layer.borderColor = Colors.Button.get().cgColor
  }
  
  private func addButtons(){
    
    let okString : NSAttributedString = NSAttributedString.init(string: "Done", attributes: [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W3", size: 22)!,NSAttributedString.Key.foregroundColor: Colors.HeaderText.get()])
    let cancelString : NSAttributedString = NSAttributedString.init(string: "Cancel", attributes: [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W3", size: 22)!,NSAttributedString.Key.foregroundColor: Colors.HeaderText.get()])
    
    let buttonHeight : CGFloat = self.popView.frame.height * 0.2
    
    let okButton : UIButton = UIButton(frame: CGRect(x: 0, y: self.popView.frame.height - buttonHeight, width: self.popView.frame.width/2, height: buttonHeight))
    okButton.backgroundColor = Colors.Background.get()
    okButton.setAttributedTitle(okString, for: .normal)
    okButton.layer.borderWidth = 3.0
    okButton.layer.cornerRadius = 30
    okButton.layer.borderColor = Colors.Button.get().cgColor
    okButton.addTarget(self, action: #selector(PopUp.okAction), for: .touchUpInside)
    if parseFunction == nil {
      okButton.frame =  CGRect(x: 0, y: self.popView.frame.height - buttonHeight, width: self.popView.frame.width, height: buttonHeight)
      if #available(iOS 11.0, *) {
        okButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
      }
      self.popView.addSubview(okButton)
      return
    }
    if #available(iOS 11.0, *) {
      okButton.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    self.popView.addSubview(okButton)
    let cancelButton : UIButton = UIButton(frame: CGRect(x: self.popView.frame.width/2, y: self.popView.frame.height - buttonHeight, width: self.popView.frame.width/2, height: buttonHeight))
    cancelButton.backgroundColor = Colors.Background.get()
    cancelButton.setAttributedTitle(cancelString, for: .normal)
    cancelButton.layer.borderWidth = 3.0
    cancelButton.layer.borderColor = Colors.Button.get().cgColor
    cancelButton.layer.cornerRadius = 30
    if #available(iOS 11.0, *) {
      cancelButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }
    cancelButton.addTarget(self, action: #selector(PopUp.cancelAction), for: .touchUpInside)
    self.popView.addSubview(cancelButton)
  }
  
  private func addTitleAndMessage(_ title: String, _ message: String){
    let width : CGFloat = self.popView.frame.width
    
    let titleString : NSAttributedString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W3", size: 25)!,NSAttributedString.Key.foregroundColor: Colors.HeaderText.get()])
    
    let titleLabel : UILabel = UILabel()
    titleLabel.textAlignment = .center
    titleLabel.attributedText = titleString
    let titleSize : CGSize = self.adjustLabelForString(titleString, titleLabel, width)
    titleLabel.frame = CGRect(origin: CGPoint(x: (width-titleSize.width)/2, y: currentY), size: titleSize)
    currentY+=titleSize.height+5
    self.popView.addSubview(titleLabel)
    
    let messageString : NSAttributedString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font: UIFont(name: "HiraginoSans-W3", size: 17)!,NSAttributedString.Key.foregroundColor: Colors.HeaderText.get()])
    
    let messageLabel : UILabel = UILabel()
    messageLabel.textAlignment = .center
    messageLabel.attributedText = messageString
    let messageSize : CGSize = self.adjustLabelForString(messageString, messageLabel, width)
    messageLabel.frame = CGRect(origin: CGPoint(x: (width-messageSize.width)/2, y: currentY), size: messageSize)
    currentY+=messageSize.height+15
    self.popView.addSubview(messageLabel)
  }
  
  private func addFields(){
    let viewWidth : CGFloat = self.popView.frame.width * 0.8
    for placeholder in inputHeaders {
      let field : UITextField = UITextField()
      field.delegate = self
      field.textColor = Colors.Text.get()
      field.placeholder = placeholder
      field.frame = CGRect(x: (self.popView.frame.width-viewWidth)/2, y: currentY, width: viewWidth, height: 25)
      field.backgroundColor = Colors.Header.get()
      currentY+=30
      self.fields.append(field)
      self.popView.addSubview(field)
    }
  }
  
  private func adjustLabelForString(_ text: NSAttributedString, _ label: UILabel, _ width: CGFloat)->CGSize{
    let size : CGSize = text.size()
    let lines : Int = Int(ceil(Double(size.width/width)))
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    let width : CGFloat = min(size.width, self.view.frame.width*0.7)
    return CGSize(width: width, height: size.height*CGFloat(lines))
  }
    
  
  @objc private func okAction(){
    guard parseFunction != nil else{
      dismiss(animated: true)
      return
    }
    var res : [String] = []
    for field in fields {
      if let text = field.text {
        res.append(text)
      }
    }
    self.dismiss(animated: true){
      self.parseFunction!(res)
    }
  }
  
  @objc private func cancelAction(){
    self.dismiss(animated: true)
  }
  
  func presentPopup(){
    parentView.present(self, animated: true, completion: nil)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
