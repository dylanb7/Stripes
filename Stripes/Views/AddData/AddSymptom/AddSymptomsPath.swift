//
//  AddSymptomPath.swift
//  Stripes
//
//  Created by Dylan Baker on 5/9/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class AddSymptomsPath : TableDataView {
  
  private var isStart : Bool = true
  
  private var isBMCheck : Bool = false
  
  private var observer : QuestionObserver?
  
  var toggled : [String : (Bool, CGFloat?)] = [:]
  
  private var questionData : [String : Question] = [:]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.register(symptomCell.self, forCellReuseIdentifier: "SymptomCell")
    self.top = "Choose type"
    self.dataSource = getTypeTableData()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    super.tableView(tableView, didSelectRowAt: indexPath)
    let data : tableData = self.dataForIndex(indexPath.row)
    guard data.selectable || data.hasScale else {
      if isStart {
        let type = symptomType(rawValue: data.mainText)!
        self.observer = QuestionObserver(type)
        if type == .BM {
          self.setData("Poop type", getPoopRows())
          isBMCheck = true
        } else {
          self.setData(data.mainText, questionsToData(QuestionPath().getQuestions(type)))
        }
        isStart = false
        toggled.removeAll()
        return
      }
      if isBMCheck {
        self.observer?.add([self.getBMResponse(data)])
        self.setData(symptomType.BM.rawValue, questionsToData(QuestionPath().getQuestions(.BM)))
        isBMCheck = false
        toggled.removeAll()
        return
      }
      self.observer?.add(self.getDataResponse())
      let presenter : UIViewController = self.parentView
      self.dismissView(true) {
        SubmitView(presenter, self.observer!).present(true) {
          self.escapeFunction!()
        }
      }
      toggled.removeAll()
      return
    }
    if toggled[data.mainText] == nil {
      toggled[data.mainText] = (true, nil)
    } else {
      toggled[data.mainText]!.0 = !toggled[data.mainText]!.0
    }
    tableView.beginUpdates()
    let _ = (tableView.cellForRow(at: indexPath) as! symptomCell).toggleSelection()
    tableView.endUpdates()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell : symptomCell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell") as! symptomCell
    let data : tableData = self.dataForIndex(indexPath.row)
    cell.set(self.dataForIndex(indexPath.row))
    cell.tableView = self
    guard let state = toggled[data.mainText] else { return cell }
    cell.toggle = state.0
    cell.startValue = state.1
    return cell
  }
  
  private func getPoopRows()->[tableData]{
    let imagePaths : [String] = ["poop1","poop2","poop3","poop4","poop5","poop6","poop7"]
    return imagePaths.map { path in
      return tableData(mainText: String(path.last!), image: UIImage(named: path), selectable: false, hasScale: false)
    }
  }
  
  private func getTypeTableData()->[tableData] {
    return symptomType.getOrdered().map({ type in
      return tableData(mainText: type.rawValue, image: nil, selectable: false, hasScale: false)
    })
  }
  
  private func questionsToData(_ question: [Question])->[tableData] {
    questionData.removeAll()
    for q in question {
      questionData[q.text] = q
    }
    var tdata = question.map({ q in
      return tableData(mainText: q.text, image: nil, selectable: true, hasScale: q.hasSeverity)
    })
    return tdata.addContinueElement()
  }
  
  private func getBMResponse(_ data : tableData)->Response {
    let question = Question(id: "5", text: "Average type of bm according to bristol stool chart", type: symptomType.BM.rawValue, hasSeverity: true, hasLocation: false)
    return Response(question: question, severity: CGFloat(Int(data.mainText)!), location: nil)
  }
  
  private func getDataResponse()->[Response] {
    var responses : [Response] = [Response]()
    for (name, (toggle, severity)) in toggled {
      
      if toggle {
        responses.append(Response(question: questionData[name]!, severity: severity == nil ? nil : round(severity!*10)/10, location: nil))
      }
    }
    return responses
  }
  
}


private class symptomCell: UITableViewCell {
  
  private lazy var sideImage : UIImageView = {
    let side : UIImageView = UIImageView()
    side.clipsToBounds = true
    side.contentMode = .center
    return side
  }()
  
  private lazy var mainText : UILabel = {
    let main : UILabel = UILabel()
    main.numberOfLines = 0
    main.textAlignment = .center
    main.contentMode = .top
    main.textColor = UIColor.black
    main.fitTextToBounds()
    return main
  }()
  
  var cellText : String? {
    didSet {
      mainText.text = cellText!
    }
  }
  
  var toggle : Bool = false {
    didSet {
      if self.data.hasScale {
        self.scale.isHidden = !self.toggle
      } else if self.data.selectable {
        self.accessoryType = toggle ? .checkmark : .none
      }
    }
  }
  
  private lazy var scale : detailSlider = {
    [unowned self] in
    let slider : detailSlider = detailSlider(self)
    slider.isHidden = true
    return slider
  }()
  
  private lazy var FullVStack : UIStackView = {
    let stack : UIStackView = UIStackView()
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = StripesView.spacing
    return stack
  }()
  
  weak var tableView : AddSymptomsPath?
  
  var startValue : CGFloat? {
    didSet {
      guard let val = startValue else { return }
      scale.setSliderValue(val)
    }
  }
  
  private var data : tableData!
  
  private let spacing = StripesView.spacing
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = UIColor.white
    self.selectionStyle = .none
  }
  
  func set(_ data : tableData) {
    self.data = data
    
    self.contentView.addSubview(FullVStack)
       
    NSLayoutConstraint.activate([
      FullVStack.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor, constant: spacing),
      FullVStack.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor, constant: -spacing),
      FullVStack.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor, constant: spacing),
      FullVStack.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor, constant: -spacing)
    ])
    if data.image != nil {
      sideImage.image = data.image
    }
    FullVStack.addArrangedSubview(data.image != nil ? sideImage : mainText)
    if data.hasScale {
      FullVStack.addArrangedSubview(scale)
    }
    
    cellText = data.mainText
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    if let _ = data.image {
      self.sideImage.removeFromSuperview()
    }
    self.mainText.removeFromSuperview()
    self.FullVStack.removeFromSuperview()
    self.toggle = false
  }
  
  func toggleSelection()->Bool{
    toggle = !toggle
    return toggle
  }
  
  func fadeAll(_ alpha : CGFloat) {
    FullVStack.fadeChildren(alpha: alpha)
  }
  
}




private class detailSlider: UIStackView {
  
  private lazy var slider : UISlider = {
    [unowned self] in
    let slider : UISlider = UISlider()
    slider.maximumValue = 5
    slider.minimumValue = 0
    slider.setValue(2.5, animated: false)
    slider.isContinuous = true
    slider.addTarget(self, action: #selector(detailSlider.changeValue(_:)), for: .valueChanged)
    return slider
  }()
  
  private lazy var severityLabel : UILabel = {
    let severity : UILabel = UILabel()
    severity.textAlignment = .center
    severity.text = "Severity"
    severity.textColor = UIColor.black
    return severity
  }()
  
  private lazy var LabelHStack : UIStackView = {
    let stack : UIStackView = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .equalCentering
    return stack
  }()
  
  private let cell : symptomCell!
  
  init(_ cell: symptomCell) {
    self.cell = cell
    super.init(frame: CGRect.zero)
    self.spacing = 0
    self.axis = .vertical
    self.alignment = .fill
    self.distribution = .equalCentering
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    for i in 0...5 {
      LabelHStack.addArrangedSubview(UIView.getSeparator(width: true, withColor: UIColor.black))
      let label = UILabel()
      label.text = "\(i)"
      label.textAlignment = .center
      label.textColor = UIColor.black
      LabelHStack.addArrangedSubview(label)
    }
    LabelHStack.addArrangedSubview(UIView.getSeparator(width: true, withColor: UIColor.black))
    self.addArrangedSubview(severityLabel)
    self.addArrangedSubview(slider)
    self.addArrangedSubview(LabelHStack)
  }
  
  func setSliderValue(_ value : CGFloat) {
    slider.setValue(Float(value), animated: false)
  }
  
  @objc private func changeValue(_ sender : UISlider){
    self.cell.tableView!.toggled[cell.cellText!]!.1 = CGFloat(sender.value)
  }
  
}

