//
//  ViewAllTable.swift
//  Stripes
//
//  Created by Dylan Baker on 5/21/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class ViewAllTable : UITableViewController {
  
  private var source : [(data: Stamped, expanded: Bool)]
  
  private var computedContentViews : [customContentView] = []
  
  private let type : dataType
  
  private var selectedIndex : Int?
  
  init(_ type : dataType) {
    self.type = type
    self.source = Store.instance.getSorted(types: [self.type]).map({ stamp in
      return (stamp, false)
    })
    super.init(style: .plain)
    self.tableView.estimatedRowHeight = 1000
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.separatorInset = UIEdgeInsets(top: 0, left: StripesView.spacing*2, bottom: 0, right: StripesView.spacing*2)
    self.tableView.separatorColor = UIColor.darkGray
    self.tableView.register(allRow.self, forCellReuseIdentifier: "ViewAllCell")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    switch self.type {
      case .BMI: self.computedContentViews = source.map({ path in
        let bmiView : bmiContentView = bmiContentView()
        bmiView.addData(path)
        return bmiView
      })
      break
      case .Event: self.computedContentViews = source.map({ path in
        let eventView : eventContentView = eventContentView()
        eventView.addData(path)
        return eventView
      })
      break
      case .User: self.computedContentViews = source.map({ path in
        let symptomView : symptomContentView = symptomContentView()
        symptomView.addData(path)
        return symptomView
      })
      break
      case .Test: self.computedContentViews = source.map({ path in
        let symptomView : symptomContentView = symptomContentView()
        symptomView.addData(path)
        return symptomView
      })
      break
    }
  }
 
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data : customContentView = self.computedContentViews[indexPath.row]
    data.translatesAutoresizingMaskIntoConstraints = false
    let cell = self.tableView.dequeueReusableCell(withIdentifier: "ViewAllCell", for: indexPath) as! allRow
    cell.selectionStyle = .none
    cell.set(self.computedContentViews[indexPath.row])
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.source.count
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return self.source[indexPath.row].expanded ? .none : .delete
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let current : (data: Stamped, expanded: Bool) = self.source[indexPath.row]
      guard Store.instance.remove(current.data.time, self.type) else {
        return
      }
      /*self.source = Store.instance.getSorted(types: [self.type]).map({ stamp in
        return (stamp, false)
      })*/
      self.source.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      tableView.reloadData()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.tableView.deselectRow(at: indexPath, animated: false)
    let data : customContentView = self.computedContentViews[indexPath.row]
    let expanded : Bool = !self.source[indexPath.row].expanded
    if data.expandable {
      self.source[indexPath.row].expanded = expanded
      self.tableView.beginUpdates()
      data.toggle()
      self.tableView.endUpdates()
      if expanded {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.source[indexPath.row].expanded ? StripesView.spacing*15 : UITableView.automaticDimension
  }
  
}

private class customContentView : UIView {
  
  lazy var fullVStack : UIStackView = {
    let stack : UIStackView = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.alignment = .center
    stack.spacing = StripesView.spacing
    return stack
  }()
  
  lazy var mainText : UILabel = {
    let main : UILabel = UILabel()
    main.numberOfLines = 0
    main.isHidden = false
    main.contentMode = .top
    main.textAlignment = .center
    main.textColor = UIColor.black
    return main
  }()
  
  lazy var typeText : UILabel = {
    let type : UILabel = UILabel()
    type.numberOfLines = 0
    type.isHidden = false
    type.textAlignment = .center
    type.textColor = UIColor.black
    return type
  }()
  
  lazy var dateText : UILabel = {
    let date : UILabel = UILabel()
    date.isHidden = false
    date.numberOfLines = 0
    date.textAlignment = .center
    date.textColor = UIColor.black
    return date
  }()
  
  lazy var scrollView : SwipeableScrollView = {
    let scroll = SwipeableScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    scroll.showsVerticalScrollIndicator = true
    scroll.showsHorizontalScrollIndicator = false
    scroll.bounces = false
    scroll.isHidden = true
    return scroll
  }()
  
  lazy var scrollStack : UIStackView = {
    let stack : UIStackView = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.alignment = .center
    stack.distribution = .equalSpacing
    stack.spacing = StripesView.spacing
    return stack
  }()
  
  var title : String? {
    didSet {
      self.mainText.text = title!
      self.mainText.isHidden = false
    }
  }
  
  var type : String? {
    didSet {
      self.typeText.text = type!
      self.typeText.isHidden = false
    }
  }
  
  var date : String? {
    didSet {
      self.dateText.isHidden = false
      self.dateText.text = date!
    }
  }
  
  var expandable : Bool = true
  
  private var toggled : Bool = false{
    didSet {
      guard expandable else { return }
      UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: .calculationModePaced, animations: {
        self.scrollView.isHidden = !self.toggled
      }, completion: nil)
    }
  }
  
  init() {
    
    
    super.init(frame: CGRect.zero)
    
    self.addSubview(fullVStack)
    
    NSLayoutConstraint.activate([
      self.fullVStack.topAnchor.constraint(equalTo: self.topAnchor, constant: StripesView.spacing),
      self.fullVStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: StripesView.spacing),
      self.fullVStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -StripesView.spacing),
      self.fullVStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -StripesView.spacing)
    ])
       
    self.fullVStack.addArrangedSubview(mainText)
    self.fullVStack.addArrangedSubview(typeText)
    self.fullVStack.addArrangedSubview(dateText)
        
    self.fullVStack.addArrangedSubview(scrollView)
    
    self.scrollView.addSubview(scrollStack)
    
    NSLayoutConstraint.activate([
      self.scrollStack.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
      self.scrollStack.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
      self.scrollStack.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
      self.scrollStack.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
    ])
    
    self.scrollView.widthAnchor.constraint(equalTo: self.scrollStack.widthAnchor).isActive = true
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addData(_ path : (data : Stamped, expanded : Bool)) {
    self.date = path.data.time.toDate().cleanString(true)
  }
  
  func toggle() {
    self.toggled = !self.toggled
  }
  
}

private class symptomContentView : customContentView {
  
  private lazy var descLabel : UILabel = {
    let desc : UILabel = UILabel()
    desc.numberOfLines = 0
    desc.textAlignment = .center
    desc.contentMode = .top
    desc.textColor = UIColor.black
    return desc
  }()
  
  override func addData(_ path: (data: Stamped, expanded: Bool)) {
    super.addData(path)
    let data : SymptomData = path.data as! SymptomData
    self.title = data.type
    descLabel.text = data.desc
    
    if let imageData = data.image {
      let imageView = UIImageView(image: UIImage(data: imageData))
      self.scrollStack.addArrangedSubview(imageView)
    }
    self.scrollStack.addArrangedSubview(descLabel)
    for res in data.responses {
      self.scrollStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.darkGray))
      let question : UILabel = UILabel()
      question.numberOfLines = 0
      question.textAlignment = .center
      question.textColor = UIColor.black
      question.contentMode = .right
      question.text = res.question.text
      self.scrollStack.addArrangedSubview(question)
      if let sev = res.severity {
        let severity : UILabel = UILabel()
        severity.numberOfLines = 0
        severity.textAlignment = .center
        severity.textColor = UIColor.black
        severity.contentMode = .right
        severity.text = "Severity: \(sev)/5"
        self.scrollStack.addArrangedSubview(severity)
      }
      if res.question.hasLocation && res.location != nil {
        let location : UILabel = UILabel()
        location.numberOfLines = 0
        location.textAlignment = .center
        location.contentMode = .right
        location.textColor = UIColor.black
        location.text = "Location: \(res.location!)/5"
        self.scrollStack.addArrangedSubview(location)
      }
    }
  }
  
}

private class bmiContentView : customContentView {
  
  override func addData(_ path: (data: Stamped, expanded: Bool)) {
    super.addData(path)
    self.expandable = false
    let data : BMIData = path.data as! BMIData
    self.title = "Height: \(data.feet)'\(data.inches), Weight: \(data.weight) pounds"
    self.type = "BMI: \(data.bmi)"
  }
  
}

private class eventContentView : customContentView {
  
  
  override func addData(_ path: (data: Stamped, expanded: Bool)) {
    super.addData(path)
    let data : EventData = path.data as! EventData
    self.title = data.type
    self.scrollStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.darkGray))
    for curr in data.desc {
      let event : UILabel = UILabel()
      event.numberOfLines = 0
      event.textAlignment = .center
      event.textColor = UIColor.black
      event.contentMode = .right
      event.text = curr
      self.scrollStack.addArrangedSubview(event)
    }
  }
  
}

private class allRow : UITableViewCell {
  
  private var current : customContentView?
  
  func set(_ content : customContentView) {
    self.backgroundColor = UIColor.white
    self.contentView.addSubview(content)
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      content.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: StripesView.spacing),
      content.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -StripesView.spacing),
      content.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])
    self.current = content
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    if current != nil && self.contentView.subviews.contains(current!) {
      current!.removeFromSuperview()
    }
    
  }
  
  
}
