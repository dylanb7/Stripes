//
//  GraphRow.swift
//  Stripes
//
//  Created by Dylan Baker on 7/5/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit
import Charts

class GraphRow: UITableViewCell {
  
  var indexPath : IndexPath!
  
  var delegate : buttonTapped!
  
  private lazy var verticalStack : UIStackView = {
    let stack : UIStackView = UIStackView()
    stack.axis = .vertical
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  
  private lazy var sparkGraph : BubbleChartView = {
    let graph : BubbleChartView = simpleGraph()
    graph.translatesAutoresizingMaskIntoConstraints = false
    return graph
  }()
  
  private lazy var questionLabel : UILabel = {
    let label : UILabel = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 0
    label.textColor = .black
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var showButton : UIButton = {
    let show : UIButton = UIButton(frame: CGRect.zero)
    show.setTitleColor(Colors.Text.get(), for: .normal)
    show.backgroundColor = Colors.Button.get()
    show.layer.cornerRadius = 5
    show.layer.borderColor = Colors.HeaderText.get().cgColor
    show.layer.borderWidth = 2.0
    show.addTarget(self, action: #selector(GraphRow.showAction), for: .touchUpInside)
    show.translatesAutoresizingMaskIntoConstraints = false
    return show
  }()
  
  private lazy var currentButton : UIButton = {
    let current : UIButton = UIButton(frame: CGRect.zero)
    current.setTitleColor(Colors.Text.get(), for: .normal)
    current.backgroundColor = Colors.Button.get()
    current.layer.cornerRadius = 5
    current.layer.borderColor = Colors.HeaderText.get().cgColor
    current.titleLabel?.numberOfLines = 0
    current.layer.borderWidth = 2.0
    current.addTarget(self, action: #selector(GraphRow.currentAction), for: .touchUpInside)
    current.isHidden = true
    current.translatesAutoresizingMaskIntoConstraints = false
    return current
  }()
  
  private var dataSet : (set : BubbleChartDataSet, lines : [ChartLimitLine])? {
    didSet {
      self.sparkGraph.resetZoom()
      dataSet!.set.setColor(NSUIColor.black)
      dataSet!.set.drawValuesEnabled = false
      self.sparkGraph.data = BubbleChartData(dataSet: dataSet?.set)
      guard !dataSet!.lines.isEmpty else { return }
      self.sparkGraph.data?.dataSets.first?.setColor(UIColor.clear)
      for line in dataSet!.lines {
        self.sparkGraph.xAxis.addLimitLine(line)
      }
    }
  }
  
  private var question : String = "" {
    didSet {
      self.questionLabel.text = question
    }
  }
  
  private var shown : Bool = false {
    didSet {
      self.showButton.setTitle(shown ? "Remove" : "Show", for: .normal)
    }
  }
  
  private var toggled : Bool = false {
    didSet {
      sparkGraph.isHidden = !toggled
      currentButton.isHidden = current == nil ? true : !toggled
      if !sparkGraph.isHidden {
        sparkGraph.animate(xAxisDuration: 0.3)
      }
    }
  }
  
  private var current : String? = "" {
    didSet {
      guard let curr = current else { return }
      self.currentButton.setTitle("Currently showing \(curr)", for: .normal)
    }
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    self.backgroundColor = UIColor.white
    self.contentView.addSubview(verticalStack)
    NSLayoutConstraint.activate([
      self.verticalStack.topAnchor.constraint(equalTo: self.contentView.topAnchor),
      self.verticalStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
      self.verticalStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
      self.verticalStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
    ])
    
    let hStack : UIStackView = UIStackView()
    hStack.axis = .horizontal
    hStack.addArrangedSubview(questionLabel)
    hStack.addArrangedSubview(showButton)
    
    questionLabel.widthAnchor.constraint(equalTo: hStack.widthAnchor, multiplier: 0.7).isActive = true
    
    self.verticalStack.addArrangedSubview(hStack)
    
    self.verticalStack.addArrangedSubview(sparkGraph)
    
    self.verticalStack.addArrangedSubview(currentButton)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(_ question : String, _ dataSet : BubbleChartDataSet, _ limitLines : [ChartLimitLine], _ shown : Bool, _ current : String?, _ toggled : Bool) {
    self.question = question
    self.dataSet = (dataSet, limitLines)
    self.shown = shown
    self.current = current
    self.toggled = toggled
  }
  
  func toggle() {
    self.toggled = !self.toggled
  }
  
  @objc private func showAction() {
    self.delegate.showTapped(indexPath)
  }
  
  @objc private func currentAction() {
    self.delegate.currentTapped(indexPath)
  }
  
}

class simpleGraph : BubbleChartView {
  
  init() {
    super.init(frame: CGRect.zero)
    self.pinchZoomEnabled = false
    self.doubleTapToZoomEnabled = false
    self.xAxis.axisLineColor = UIColor.black
    self.leftAxis.axisLineColor = UIColor.black
    self.leftAxis.drawLabelsEnabled = false
    self.leftAxis.axisLineWidth = 3.0
    self.leftAxis.drawGridLinesEnabled = false
    self.xAxis.drawLabelsEnabled = false
    self.xAxis.drawGridLinesEnabled = false
    self.xAxis.labelPosition = .bottom
    self.xAxis.axisLineWidth = 3.0
    self.rightAxis.drawAxisLineEnabled = false
    self.rightAxis.drawLabelsEnabled = false
    self.rightAxis.drawGridLinesEnabled = false
    self.legend.enabled = false
    self.backgroundColor = Colors.Background.get()
    self.roundCorners(20)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

protocol buttonTapped {
  
  func showTapped(_ index : IndexPath)
  
  func currentTapped(_ index : IndexPath)
  
}
