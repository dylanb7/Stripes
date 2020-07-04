//
//  PopUp.swift
//  Stripes
//
//  Created by Dylan Baker on 5/3/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class PopUp: UIViewController {
  
  lazy var titleLabel : UILabel = {
    [unowned self] in
    let title : UILabel = UILabel(frame: CGRect.zero)
    title.textAlignment = .center
    title.text = self.header
    title.font = UIFont(name: "HiraginoSans-W3", size: 20)!
    title.textColor = Colors.HeaderText.get()
    title.translatesAutoresizingMaskIntoConstraints = false
    return title
  }()
  
  static let size : CGSize = UIScreen.main.bounds.size
  
  let popSize : CGSize!
  
  lazy var buttonHeightConstant : CGFloat = {
    [unowned self] in
    return self.popSize.height * 0.2
  }()
  
  lazy var viewWidth : CGFloat = {
    [unowned self] in
    return self.popSize.width * 0.8
  }()
  
  lazy var spacing = PopUp.size.height * 0.025
  
  private let header : String!
  
  var parentView: UIViewController!
  
  let popDelegate : PopDelegate?
  
  init(_ parent: UIViewController, _ title : String, _ popDelegate : PopDelegate?) {
    self.popDelegate = popDelegate
    self.parentView = parent.parent ?? parent
    self.header = title
    self.popSize = CGSize(width: PopUp.size.width * 0.8, height: PopUp.size.height * 0.4)
    super.init(nibName: nil, bundle: nil)
    self.view.frame = CGRect.zero
    self.view.translatesAutoresizingMaskIntoConstraints = false
    self.view.backgroundColor = Colors.Background.get()
    self.view.layer.cornerRadius = 30
    self.view.layer.masksToBounds = false
    self.view.layer.borderWidth = 5.0
    self.view.layer.borderColor = Colors.Button.get().cgColor
    self.view.alpha = 0.0
    self.modalPresentationStyle = .overCurrentContext
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()

  }
  
  override func viewDidLoad() {
    self.parentView.view.addSubview(self.view)
    NSLayoutConstraint.activate([
      self.view.centerXAnchor.constraint(equalTo: self.parentView.view.centerXAnchor),
      self.view.centerYAnchor.constraint(equalTo: self.parentView.view.centerYAnchor),
      self.view.widthAnchor.constraint(equalToConstant: PopUp.size.width * 0.8),
      self.view.heightAnchor.constraint(equalToConstant: PopUp.size.height * 0.4)
    ])
    
    self.view.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: spacing),
      titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      titleLabel.widthAnchor.constraint(equalToConstant: viewWidth),
      titleLabel.heightAnchor.constraint(equalToConstant: spacing*3),
    ])
    self.popDelegate?.didLoad(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    titleLabel.fitTextToBounds()
  }
  
  func presentPopup() {
    if parentView is BaseDataView {
      parentView.modalPresentationStyle = .overCurrentContext
    }
    parentView.present(self, animated: false, completion: {
      NSLayoutConstraint.activate([
        self.view.centerXAnchor.constraint(equalTo: self.parentView.view.centerXAnchor),
        self.view.centerYAnchor.constraint(equalTo: self.parentView.view.centerYAnchor)
      ])
      UIView.animate(withDuration: 0.3, animations: {
        self.view.alpha = 1.0
      })
    })
  }
  
  func dismissPopup(_ animated: Bool, _ after : @escaping ()->()) {
    let duration : TimeInterval = animated ? 0.3 : 0
    UIView.animate(withDuration: duration, animations: {
      self.view.alpha = 0.0
    }, completion: { finish in
      self.dismiss(animated: false, completion: nil)
      self.popDelegate?.didDismiss(self)
      after()
    })
  }
  
}
