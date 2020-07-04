//
//  ButtonPopUp.swift
//  Stripes
//
//  Created by Dylan Baker on 3/13/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//
import UIKit

class ButtonPopUp : PopUp {
  
  private var buttons : [UIButton] = []
  
  private var currentY : CGFloat?
  
  private let inputHeaders: [String]!
  
  private let parseFunction: ((String)->Void)?
  
  private let currentSelection : Int?
  
  private lazy var scrollView : SwipeableScrollView = {
    let scroll : SwipeableScrollView = SwipeableScrollView(frame: CGRect.zero)
    scroll.showsVerticalScrollIndicator = true
    scroll.translatesAutoresizingMaskIntoConstraints = false
    return scroll
  }()
  
  init(_ parent: UIViewController, _ header: String, _ inputHeaders: [String], _ currentSelection : Int?, _ popDelegate : PopDelegate?, _ parseFunction: ((_ res: String)->Void)?) {
    self.parseFunction = parseFunction
    self.inputHeaders = inputHeaders
    self.currentSelection = currentSelection
    super.init(parent, header, popDelegate)
    self.currentY = self.popSize!.height * 0.07
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addButtons()
  }
  
  
  private func addButtons(){
    self.view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      scrollView.widthAnchor.constraint(equalToConstant: viewWidth),
      scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -spacing)
    ])
    
    var topAnchor = scrollView.topAnchor
    let index : Int = currentSelection ?? -1
    for i in 0..<inputHeaders.count {
      let button : UIButton = UIButton(type: .custom)
      button.titleLabel?.font = UIFont(name: "HiraginoSans-W3", size: 20)!
      button.setTitleColor(Colors.Text.get(), for: .normal)
      button.roundCorners(10)
      button.backgroundColor = i == index ? Colors.HeaderText.get() : Colors.Button.get()
      button.setTitle(inputHeaders[i], for: .normal)
      button.addTarget(self, action: #selector(ButtonPopUp.clickAction(_:)), for: .touchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      buttons.append(button)
      scrollView.addSubview(button)
      
      NSLayoutConstraint.activate([
        button.topAnchor.constraint(equalTo: topAnchor, constant: spacing/2),
        button.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        button.widthAnchor.constraint(equalToConstant: viewWidth*0.9),
        button.heightAnchor.constraint(equalToConstant: spacing*3)
      ])
    
      topAnchor = button.bottomAnchor
    }
    
    scrollView.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
  }
  
  @objc func clickAction(_ sender : Any?){
    let button : UIButton = sender as! UIButton
    for b in buttons {
      b.backgroundColor = Colors.Button.get()
    }
    
    button.backgroundColor = Colors.HeaderText.get()
    guard parseFunction != nil else{
      self.dismissPopup(true){}
      return
    }
    self.dismissPopup(true) {
      self.parseFunction!(button.currentTitle ?? "")
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
