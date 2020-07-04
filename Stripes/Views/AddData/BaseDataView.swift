//
//  BaseDataView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/9/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class BaseDataView: UIViewController {
  
  let parentView : UIViewController!
  
  let spacing : CGFloat = StripesView.spacing
  
  private var widthConstraint : NSLayoutConstraint?
  
  private var heightContraint : NSLayoutConstraint?
  
  var escapeFunction : (()->Void)?
  
  var width : CGFloat?
  
  var height : CGFloat?
  
  var yoffset : CGFloat?
  
  lazy var dismissButton : UIButton = {
    let dismiss : UIButton = UIButton()
    dismiss.backgroundColor = Colors.Button.get()
    dismiss.setTitle("Dismiss", for: .normal)
    dismiss.setTitleColor(Colors.Text.get(), for: .normal)
    dismiss.clipsToBounds = true
    //dismiss.roundCorners(20)
    dismiss.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    dismiss.translatesAutoresizingMaskIntoConstraints = false
    dismiss.addTarget(self, action: #selector(BaseDataView.dismissSelf), for: .touchUpInside)
    return dismiss
  }()
  
  init(_ under : UIViewController) {
    self.parentView = under
    super.init(nibName: nil, bundle: nil)
    self.view.frame = CGRect.zero
    self.view.translatesAutoresizingMaskIntoConstraints = false
    self.view.alpha = 0.0
    self.view.backgroundColor = Colors.Background.get()
    //self.view.roundCorners(20)
    self.view.clipsToBounds = false
    self.view.layer.shadowColor = UIColor.black.cgColor
    self.view.layer.shadowOpacity = 1
    self.view.layer.shadowOffset = .zero
    self.view.layer.shadowRadius = 10
    self.modalPresentationStyle = .overCurrentContext
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.parentView.view.addSubview(self.view)
    
    self.widthConstraint = NSLayoutConstraint(item: self.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PopUp.size.width)
    self.heightContraint = NSLayoutConstraint(item: self.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PopUp.size.height)
    
    NSLayoutConstraint.activate([
      self.widthConstraint!,
      self.heightContraint!
    ])
    
    self.view.addSubview(dismissButton)
    
    NSLayoutConstraint.activate([
      dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      dismissButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      dismissButton.heightAnchor.constraint(equalToConstant: 50)
    ])
    
  }
  
  func present(_ animated : Bool, _ completion : @escaping ()->Void) {
    self.escapeFunction = completion
    let w = width ?? 0.9
    let h = height ?? 0.85
    let duration : TimeInterval =  animated ? 0.4 : 0
    (parentView.tabBarController ?? parentView.parent ?? parentView).present(self, animated: false, completion: {
      NSLayoutConstraint.activate([
        self.view.centerXAnchor.constraint(equalTo: self.parentView.view.centerXAnchor),
        self.view.centerYAnchor.constraint(equalTo: self.parentView.view.centerYAnchor, constant: self.yoffset ?? 0)
      ])
      self.view.fadeChildren(alpha: 0.0)
      UIView.animate(withDuration: duration, animations: {
        self.view.alpha = 1.0
        self.parentView.tabBarController?.tabBar.items?.forEach({ item in
          item.isEnabled = false
        })
        self.widthConstraint?.constant = (PopUp.size.width * w)
        self.heightContraint?.constant = (PopUp.size.height * h)
        self.view.superview!.layoutIfNeeded()
      }, completion: { res in
        UIView.animate(withDuration: duration/2) {
          self.view.fadeChildren(alpha: 1)
        }
      })
    })
  }
  
  func dismissView(_ animated : Bool, completion : @escaping ()->Void) {
    let duration : TimeInterval = animated ? 0.4 : 0
    UIView.animate(withDuration: duration, animations: {
      self.view.alpha = 0.0
      self.parentView.tabBarController?.tabBar.items?.forEach({ item in
        item.isEnabled = true
      })
      self.parentView.tabBarController?.tabBar.alpha = 1.0
      self.view.superview!.layoutIfNeeded()
    }, completion: { finish in
      self.dismiss(animated: false, completion: {
        completion()
      })
    })
  }
  
  @objc func dismissSelf() {
    UIView.animate(withDuration: 0.4, animations: {
      self.view.alpha = 0.0
      self.parentView.tabBarController?.tabBar.items?.forEach({ item in
        item.isEnabled = true
      })
      self.parentView.tabBarController?.tabBar.alpha = 1.0
      self.view.superview!.layoutIfNeeded()
    }, completion: { finish in
      self.dismiss(animated: false, completion: nil)
    })
  }
  
}
