//
//  SlidingButton.swift
//  Stripes
//
//  Created by Dylan Baker on 5/5/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class SlidingButton: UIView {
  
  var textColor : UIColor = UIColor.white {
    didSet {
      self.currentOption.textColor = textColor
    }
  }
  
  var arrowColor : UIColor = UIColor.white
  
  var animationSpeed : TimeInterval = 0.2 {
    didSet {
      animationSpeed = animationSpeed/2
    }
  }
  
  private var switchFunction : (String)->()
  
  private var options: [String : (()->Void)] = [:]
  
  private var current : slide? {
    didSet {
      guard self.superview != nil else { return }
      self.switchFunction(current!.name)
      currentOption.text = current!.name!
      currentOption.fitTextToBounds()
    }
  }
  
  private lazy var currentOption : UILabel = {
    [unowned self] in
    let label : UILabel = UILabel(frame: CGRect.zero)
    label.textColor = self.textColor
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
   
  
  private var isAnimating : Bool = false {
    didSet {
      self.setNeedsDisplay()
    }
  }
  
  private var centerXConstraint : NSLayoutConstraint?
  
  init(_ frame: CGRect, _ options: [String], _ startIndex : Int?) {
    for i in 0..<options.count {
      self.options[options[i]] = {}
    }
    self.switchFunction = {text in}
    super.init(frame: frame)
    self.addGestures()
    self.circleStructure(options, startIndex ?? 0)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func getCurrentText()->String {
    return self.current!.name
  }
  
  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    self.addSubview(currentOption)
    
    centerXConstraint = NSLayoutConstraint(item: currentOption, attribute:  .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
    
    NSLayoutConstraint.activate([
      centerXConstraint!,
      currentOption.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      currentOption.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
      currentOption.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9)
    ])
    
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    self.currentOption.text = self.current?.name
    self.currentOption.fitTextToBounds()
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    guard !isAnimating else { return }
    
    let spacing : CGFloat = rect.width*0.06
    let width : CGFloat = (rect.width*0.1)-spacing
    let height : CGFloat = width*1.7
    let top : CGFloat = (rect.height - height)/2
    let lineWidth : CGFloat = 3.0
    
    let rightArrowPath : UIBezierPath = UIBezierPath()
    let rightRect : CGRect = CGRect(x: rect.width-width-spacing, y: top, width: width, height: height)
    rightArrowPath.lineWidth = lineWidth
    
    rightArrowPath.move(to: CGPoint(x: rightRect.minX, y: rightRect.minY))
    rightArrowPath.addLine(to: CGPoint(x: rightRect.maxX, y: rightRect.midY))
    rightArrowPath.addLine(to: CGPoint(x: rightRect.minX, y: rightRect.maxY))
    
    let leftArrowPath : UIBezierPath = UIBezierPath()
    let leftRect : CGRect = CGRect(x: spacing, y: top, width: width, height: height)
    leftArrowPath.lineWidth = lineWidth
    
    leftArrowPath.move(to: CGPoint(x: leftRect.maxX, y: leftRect.minY))
    leftArrowPath.addLine(to: CGPoint(x: leftRect.minX, y: leftRect.midY))
    leftArrowPath.addLine(to: CGPoint.init(x: leftRect.maxX, y: leftRect.maxY))
    
    arrowColor.setStroke()
    rightArrowPath.stroke()
    leftArrowPath.stroke()
    
  }
  
  private func circleStructure(_ options: [String], _ startIndex: Int) {
    current = slide(options[startIndex])
    var leftParent : slide = current!
    var rightParent : slide = current!
    var leftIndex : Int = startIndex-1 < 0 ? options.count-1 : startIndex-1
    var rightIndex : Int = startIndex+1 > options.count-1 ? 0 : startIndex+1
    for _ in 1..<options.count {
      let leftLabel : slide = slide(options[leftIndex])
      let rightLabel : slide = slide(options[rightIndex])
      leftLabel.right = leftParent
      rightLabel.left = rightParent
      leftParent.left = leftLabel
      rightParent.right = rightLabel
      leftParent = leftLabel
      rightParent = rightLabel
      leftIndex = leftIndex-1 < 0 ? options.count-1 : leftIndex-1
      rightIndex = rightIndex+1 > options.count-1 ? 0 : rightIndex+1
    }
    leftParent.left = current
    rightParent.right = current
  }
  
  private func addGestures(){
    let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SlidingButton.buttonTapped))
    
    let left : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SlidingButton.viewSwiped(_:)))
    left.direction = .left
    
    let right : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SlidingButton.viewSwiped(_:)))
    right.direction = .right
    
    self.addGestureRecognizer(tap)
    self.addGestureRecognizer(left)
    self.addGestureRecognizer(right)
  }
  
  func addAction(_ option : String, _ action : @escaping (()->Void)) {
    if !options.keys.contains(option) { return }
    options[option] = action
  }
  
  func addSwitchFunction(_ function : @escaping (String)->()) {
    self.switchFunction = function
  }
  
  @objc private func buttonTapped(){
    guard !isAnimating else { return }
    self.options[self.current!.name]!()
  }
  
  @objc private func viewSwiped(_ sender : UISwipeGestureRecognizer){
    guard !isAnimating else { return }
    switch sender.direction {
      case .left:
        self.swipeAnimation(isRight: false)
      case .right:
        self.swipeAnimation(isRight: true)
      default:
        return
    }
  }
  
  private func swipeAnimation(isRight : Bool){
    
    self.isAnimating = true
    
    let edge : CGFloat = (self.frame.width/2)+(self.currentOption.frame.width/2)
    let start : CGFloat = isRight ? edge : -edge
    let mid : CGFloat = -start
    
    UIView.animate(withDuration: self.animationSpeed, animations: {
      self.centerXConstraint?.constant = start
      self.currentOption.alpha = 0.0
      self.layoutIfNeeded()
    }, completion: { bool in
      
      self.current! = isRight ? self.current!.left! : self.current!.right!
      
      self.centerXConstraint?.constant = mid
      self.layoutIfNeeded()
      
      UIView.animate(withDuration: self.animationSpeed, animations:  {
        self.centerXConstraint?.constant = 0
        self.currentOption.alpha = 1.0
        self.layoutIfNeeded()
      }, completion: { bool in
        self.isAnimating = false
      })
      
    })
    
  }
  
  internal class slide {
    
    var left : slide?
    
    var right : slide?
    
    let name : String!
    
    init(_ name : String) {
      self.name = name
    }
    
  }
  
}
