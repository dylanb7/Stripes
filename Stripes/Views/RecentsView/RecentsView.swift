//
//  RecentsView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/13/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class RecentsView : UIView {
  
  private lazy var recentsLabel : UILabel = {
    [unowned self] in
    let recents : UILabel = UILabel()
    recents.numberOfLines = 1
    recents.textColor = Colors.Text.get()
    recents.backgroundColor = Colors.Header.get()
    recents.roundCorners(10)
    recents.textAlignment = .center
    recents.widthAnchor.constraint(equalToConstant: self.spacing*10).isActive = true
    recents.heightAnchor.constraint(equalToConstant: self.spacing*2).isActive = true
    recents.translatesAutoresizingMaskIntoConstraints = false
    return recents
  }()
  
  private lazy var noDataLabel : UILabel = {
    let noData : UILabel = UILabel()
    noData.numberOfLines = 1
    noData.textColor = Colors.Text.get()
    noData.backgroundColor = Colors.Header.get()
    noData.roundCorners(10)
    noData.textAlignment = .center
    noData.widthAnchor.constraint(equalToConstant: self.spacing*12).isActive = true
    noData.heightAnchor.constraint(equalToConstant: self.spacing*2).isActive = true
    noData.translatesAutoresizingMaskIntoConstraints = false
    return noData
  }()
  
  private lazy var scrollView : UIScrollView = {
    let scroll : UIScrollView = UIScrollView()
    /*scroll.layer.borderWidth = 3.0
    scroll.layer.borderColor = Colors.HeaderText.get().cgColor
    scroll.roundCorners(10)
    scroll.backgroundColor = Colors.Background.get()*/
    scroll.showsVerticalScrollIndicator = false
    scroll.translatesAutoresizingMaskIntoConstraints = false
    return scroll
  }()
  
  private var dataSource : [Stamped]  = [] {
    didSet {
      toggle(dataSource.isEmpty)
      scrollView.removeAllSubviews()
      if !dataSource.isEmpty {
        layout()
      }
      self.setNeedsLayout()
      self.setNeedsDisplay()
    }
  }
  
  var length : Int {
    get {
      return dataSource.count
    }
  }
  
  private let spacing = StripesView.spacing
  
  init() {
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    self.addSubview(recentsLabel)
    
    NSLayoutConstraint.activate([
      recentsLabel.topAnchor.constraint(equalTo: self.topAnchor),
      recentsLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
    ])
    
    self.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: recentsLabel.bottomAnchor, constant: spacing),
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
    ])
    
    scrollView.addSubview(noDataLabel)
    
    NSLayoutConstraint.activate([
      noDataLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      noDataLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ])
    
  }
  
  private func layout() {
    var leadingAnchor = scrollView.leadingAnchor
    for i in 0..<dataSource.count {
      let preview  = cellForIndex(i)
      preview.translatesAutoresizingMaskIntoConstraints = false
      preview.roundCorners(5)

      preview.clipsToBounds = false
      preview.layer.shadowOffset = .zero
      preview.layer.shadowRadius = 2
      preview.layer.shadowOpacity = 1
      preview.layer.shadowColor = preview.backgroundColor!.cgColor
      scrollView.addSubview(preview)
      NSLayoutConstraint.activate([
        preview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
        preview.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        preview.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
      ])
      NSLayoutConstraint(item: preview, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: -spacing).isActive = true
      leadingAnchor = preview.trailingAnchor
    }
    scrollView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: spacing).isActive = true
  }
  
  private func cellForIndex(_ index : Int) ->UIView {
    let data = dataSource[index]
    if let symptom = data as? SymptomData {
      let symptomView = symptomPreview(symptom)
      symptomView.backgroundColor = typeColors(data: symptomType(rawValue: symptom.type), event: nil).get()
      return symptomView
    } else if let event = data as? EventData {
      let eventView = eventPreview(event)
      eventView.backgroundColor = typeColors(data: nil, event: eventType(rawValue: event.type)).get()
      return eventView
    } else if let bmi = data as? BMIData {
      let bmiView = BMIPreview(bmi)
      bmiView.backgroundColor = Colors.Header.get()
      return bmiView
    }
    let recents = recentsPreview(data.time)
    recents.backgroundColor = typeColors(data: symptomType(rawValue: (data as! SymptomData).type), event: nil).get()
    return recents
  }
  
  private func toggle(_ isHidden : Bool) {
    noDataLabel.isHidden = !isHidden
  }
  
  func set(_ data : dataType) {
    self.dataSource = Store.instance.getSorted(types: [data])
    self.recentsLabel.text = "Recent \(data.rawValue)s"
    self.noDataLabel.text = "No \(data.rawValue) Data"
    self.recentsLabel.fitTextToBounds()
    self.noDataLabel.fitTextToBounds()
  }
  
}

class recentsPreview: UIView {
  
  lazy var dateLabel : UILabel = {
    let dateLabel : UILabel = UILabel()
    dateLabel.textColor = Colors.Text.get()
    dateLabel.numberOfLines = 0
    return dateLabel
  }()
  
  private lazy var scrollView : UIScrollView = {
    let scroll : UIScrollView = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    scroll.showsVerticalScrollIndicator = false
    scroll.showsHorizontalScrollIndicator = false
    scroll.bounces = false
    return scroll
  }()
  
  lazy var verticalStack : UIStackView = {
    [unowned self] in
    let vertical : UIStackView = UIStackView()
    vertical.translatesAutoresizingMaskIntoConstraints = false
    vertical.axis = .vertical
    vertical.alignment = .fill
    vertical.distribution = .equalSpacing
    vertical.spacing = self.spacing
    return vertical
  }()
  
  private let spacing : CGFloat = StripesView.spacing/2
  
  private let dateString : String!
  
  init(_ stamp : Int32) {
    self.dateString = stamp.toDate().cleanString(true)
    super.init(frame: CGRect.zero)
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    self.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: spacing),
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -spacing)
    ])
    
    scrollView.addSubview(verticalStack)
    
    NSLayoutConstraint.activate([
      verticalStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
      verticalStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      verticalStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      verticalStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    ])
    
    NSLayoutConstraint(item: self.verticalStack, attribute: .width, relatedBy: .equal, toItem: self.scrollView, attribute: .width, multiplier: 1, constant: 0).isActive = true
    
    self.dateLabel.text = self.dateString
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class symptomPreview : recentsPreview {
  
  private lazy var typeLabel : UILabel = {
    let type : UILabel = UILabel()
    type.textColor = Colors.Text.get()
    type.numberOfLines = 0
    type.textAlignment = .center
    return type
  }()
  
  private lazy var descriptionLabel : UILabel = {
     let description : UILabel = UILabel()
     description.textColor = Colors.Text.get()
     description.numberOfLines = 0
     description.textAlignment = .center
     return description
   }()
  
  private let symptom : SymptomData!
  
  init(_ symptom: SymptomData) {
    self.symptom = symptom
    super.init(symptom.time)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    typeLabel.text = symptom.type
    verticalStack.addArrangedSubview(typeLabel)

    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    verticalStack.addArrangedSubview(dateLabel)
    
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    let desc = symptom.desc
    descriptionLabel.text = desc.isEmpty ? "No Description" : desc
    verticalStack.addArrangedSubview(descriptionLabel)
    
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    for res in symptom.responses {
      let label : UILabel = UILabel()
      label.text = res.question.text
      label.numberOfLines = 0
      label.textColor = .white
      verticalStack.addArrangedSubview(label)
    }
  }
  
}

class eventPreview : recentsPreview {
  
  private lazy var typeLabel : UILabel = {
    let type : UILabel = UILabel()
    type.textColor = Colors.Text.get()
    type.numberOfLines = 0
    type.textAlignment = .center
    return type
  }()
  
  private let event : EventData!
  
  init(_ event: EventData) {
    self.event = event
    super.init(event.time)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    typeLabel.text = event.type
    verticalStack.addArrangedSubview(typeLabel)

    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    verticalStack.addArrangedSubview(dateLabel)
    
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    for text in event.desc {
      let desc : UILabel = UILabel()
      desc.textColor = Colors.Text.get()
      desc.numberOfLines = 0
      desc.textAlignment = .center
      desc.text = text
      verticalStack.addArrangedSubview(desc)
    }
  }
  
}

class BMIPreview: recentsPreview {
  
  private lazy var weightLabel : UILabel = {
    let weight : UILabel = UILabel()
    weight.textColor = Colors.Text.get()
    weight.numberOfLines = 0
    weight.textAlignment = .center
    return weight
  }()
  
  private lazy var heightLabel : UILabel = {
    let height : UILabel = UILabel()
    height.textColor = Colors.Text.get()
    height.numberOfLines = 0
    height.textAlignment = .center
    return height
  }()
  
  private lazy var bmiLabel : UILabel = {
    let height : UILabel = UILabel()
    height.textColor = Colors.Text.get()
    height.numberOfLines = 0
    height.textAlignment = .center
    return height
  }()
  
  private let bmiData : BMIData!
  
  init(_ bmi: BMIData) {
    self.bmiData = bmi
    super.init(bmi.time)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    
    weightLabel.text = "Weight: \(bmiData.weight) pounds"
    heightLabel.text = "Feet: \(bmiData.feet), Inches: \(bmiData.inches)"
    bmiLabel.text = "BMI: \(bmiData.bmi)"
    
    verticalStack.addArrangedSubview(weightLabel)
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    verticalStack.addArrangedSubview(heightLabel)
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    verticalStack.addArrangedSubview(bmiLabel)
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    verticalStack.addArrangedSubview(dateLabel)
  }
  
}




