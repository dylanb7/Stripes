//
//  GraphView.swift
//  Stripes
//
//  Created by Dylan Baker on 3/18/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import Foundation
import UIKit
import Charts

class GraphView : UIViewController {
  
  private lazy var graphView : BubbleChartView = {
    let bubbleChart : BubbleChartView = BubbleChartView(frame: CGRect.zero)
    bubbleChart.translatesAutoresizingMaskIntoConstraints = false
    bubbleChart.layer.borderWidth = 2.0
    bubbleChart.layer.borderColor = Colors.Header.get().cgColor
    return bubbleChart
  }()
  
  private lazy var exportButton : UIButton = {
    let export : UIButton = UIButton(frame: CGRect.zero)
    export.setTitle("Export", for: .normal)
    export.setTitleColor(Colors.Text.get(), for: .normal)
    export.backgroundColor = Colors.Button.get()
    export.roundCorners(10)
    export.layer.borderColor = Colors.HeaderText.get().cgColor
    export.layer.borderWidth = 2.0
    export.addTarget(self, action: #selector(GraphView.export), for: .touchUpInside)
    export.translatesAutoresizingMaskIntoConstraints = false
    return export
  }()
  
  private lazy var slidingButton : SlidingButton = {
    let button = SlidingButton(CGRect.zero, ["No Data"], 0)
    button.backgroundColor = Colors.Button.get()
    button.textColor = Colors.Text.get()
    button.roundCorners(10)
    button.layer.borderWidth = 3.0
    button.layer.borderColor = Colors.HeaderText.get().cgColor
    button.arrowColor = Colors.HeaderText.get()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addSwitchFunction({ to in
      self.changeSource(to, true)
    })
    return button
  }()
  
  private lazy var graphTableView : UITableView = {
    [unowned self] in
    let table : UITableView = UITableView(frame: CGRect.zero)
    table.dataSource = self
    table.delegate = self
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()
  
  private lazy var graphHeight : NSLayoutConstraint = {
    [unowned self] in
    return self.graphTableView.heightAnchor.constraint(equalToConstant: 0)
  }()
   
  private var groupTime : Calendar.Component = .month
  
  private var collapsed : Bool = false {
    didSet {
      graphHeight.constant = collapsed ? 0 :
        max((exportButton.frame.minY - slidingButton.frame.maxY - (StripesView.spacing/2)), 0)
    }
  }
  
  private var mainGraphSource : [String : (set: BubbleChartDataSet, limits: [ChartLimitLine], date: Date)] = [:]
  
  private var fullSource : [dataType : [(question : String, dataSet : BubbleChartDataSet, limitLines : [ChartLimitLine], startDate : Date, shown : Bool, current : String?, toggled : Bool)]] = [:]
  
  private var tableSource : [(question : String, dataSet : BubbleChartDataSet, limitLines : [ChartLimitLine], startDate : Date, shown : Bool, current : String?, toggled : Bool)] = [] {
    didSet {
      self.graphTableView.reloadData()
    }
  }
  
  //private var rowData : [String : (expanded : Bool, showing : Bool, current : String)] = [:]
  
  private var animating : Bool = false
  
  private lazy var bmiData : [BMIData] = {
    return Store.instance.get(type: .BMI) as! [BMIData]
  }()
  
  private lazy var eventData : [EventData] = {
    return Store.instance.get(type: .Event) as! [EventData]
  }()
  
  private lazy var questionData = QuestionGathering().questionData
  
  init() {
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(graphView)
    
    NSLayoutConstraint.activate([
      graphView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      graphView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6),
      graphView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8)
    ])
    
    self.view.addSubview(exportButton)
    NSLayoutConstraint.activate([
      exportButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      exportButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
      exportButton.heightAnchor.constraint(equalToConstant: StripesView.spacing*2.5)
    ])
    
    self.view.addSubview(slidingButton)
    NSLayoutConstraint.activate([
      slidingButton.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: StripesView.spacing/2),
      slidingButton.leadingAnchor.constraint(equalTo: exportButton.leadingAnchor),
      slidingButton.trailingAnchor.constraint(equalTo: exportButton.trailingAnchor),
      slidingButton.heightAnchor.constraint(equalTo: graphView.bottomAnchor.anchorWithOffset(to: exportButton.topAnchor), multiplier: 0.2)
    ])
    
    self.view.addSubview(graphTableView)
    NSLayoutConstraint.activate([
      graphTableView.topAnchor.constraint(equalTo: slidingButton.bottomAnchor, constant: StripesView.spacing/2),
      graphTableView.leadingAnchor.constraint(equalTo: exportButton.leadingAnchor),
      graphTableView.trailingAnchor.constraint(equalTo: exportButton.trailingAnchor),
      graphHeight
    ])
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.refreshData()
    self.updateTableData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.tableSource.removeAll()
  
    exportButton.bottomAnchor.constraint(equalTo: (self.tabBarController?.tabBar.topAnchor)!, constant: -StripesView.spacing/2).isActive = true
    graphView.topAnchor.constraint(equalTo: (navigationController?.navigationBar.bottomAnchor)!, constant: StripesView.spacing/2).isActive = true
    self.loadSlidingButton()
    changeSource(self.slidingButton.getCurrentText(), false)
    self.slidingButton.reloadGraphics()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    guard !animating else { return }
    self.collapsed = false
  }

  private func loadSlidingButton() {
    var sortedKeys : [String] = []
    self.questionData.isEmpty ? () : sortedKeys.append("\(dataType.User.rawValue) data")
    self.bmiData.isEmpty ? () : sortedKeys.append("\(dataType.BMI.rawValue) data")
    self.eventData.isEmpty ? () : sortedKeys.append("\(dataType.Event.rawValue) data")
    sortedKeys.isEmpty ? sortedKeys.append("No Data") : ()
    self.slidingButton.set(sortedKeys, 0)
  }
  
  private func changeSource(_ newSource : String, _ animated : Bool) {
    guard let type = dataType(rawValue: String(newSource.dropLast(5))) else { return }
    self.animating = true
    self.collapsed = true
    let duration = animated ? 0.2 : 0
    UIView.animate(withDuration: duration, animations: {
      self.view.layoutIfNeeded()
    }, completion: { _ in
      self.tableSource = self.fullSource[type]!
      self.collapsed = false
      UIView.animate(withDuration: duration, animations: {
        self.view.layoutIfNeeded()
      })
    })
    self.animating = false
  }
  
  private func refreshData() {
    self.bmiData = Store.instance.get(type: .BMI) as! [BMIData]
    self.eventData = Store.instance.get(type: .Event) as! [EventData]
    self.questionData = QuestionGathering().questionData
  }
  
  private func updateTableData() {
    var toggleTracker : Set<String> = Set()
    tableSource.forEach({ item in
      if item.toggled {
        toggleTracker.insert(item.question)
      }
    })
    tableSource.removeAll()
    
    //BMI
    let entrees : [BubbleChartDataEntry] = self.bmiData.map({ bmi in
      return BubbleChartDataEntry(x: Double(bmi.time), y: bmi.bmi, size: 1)
    })
    let rowName : String = "All BMI Data"
    let dataSet : BubbleChartDataSet = BubbleChartDataSet(entries: entrees)
    let start : Date = entrees.first == nil ? Date() : Date(timeIntervalSince1970: entrees.first!.x)
    let grouped : BubbleChartDataSet = groupDataSet(dataSet)
    grouped.setColor(Colors.Header.get())
    self.fullSource[.BMI] = [(rowName, grouped, [], start, self.mainGraphSource[rowName] != nil, nil, toggleTracker.contains(rowName))]
    
    //User
    self.fullSource[.User] = []
    symptomType.getOrdered().forEach({ type in
      guard let data = self.questionData[type.rawValue] else {
        return
      }
      let entrees : [BubbleChartDataEntry] = data.map({ entree in
        return BubbleChartDataEntry(x: Double(entree.time), y: 1, size: entree.severity ?? 1)
      })
      let set : BubbleChartDataSet = BubbleChartDataSet(entries: entrees)
      let start : Date = entrees.first == nil ? Date() : Date(timeIntervalSince1970: entrees.first!.x)
      self.fullSource[.User]!.append((type.rawValue, groupDataSet(set), [], start, self.mainGraphSource[type.rawValue] != nil, "All", toggleTracker.contains(type.rawValue)))
    })
    
    //Event
    self.fullSource[.Event] = []
    var eventData : [String : [ChartLimitLine]] = [:]
    for event in self.eventData {
      if let _ = eventData[event.type] {
        eventData[event.type]!.append(ChartLimitLine(limit: Double(event.time), label: event.type))
      } else {
        eventData[event.type] = [ChartLimitLine(limit: Double(event.time), label: event.type)]
      }
    }
    for (key, val) in eventData {
      let start : Date = val.first == nil ? Date() : Date(timeIntervalSince1970: val.first!.limit)
      let set : BubbleChartDataSet = BubbleChartDataSet()
      let end : Date = val.last == nil ? Date() : Date(timeIntervalSince1970: val.last!.limit)
      set.append(BubbleChartDataEntry(x: 0, y: 0, size: 0))
      set.append(BubbleChartDataEntry(x: Double(timeBetween(start, end)), y: 0, size: 0))
      for i in 0..<val.count {
        let stamp : Double = val[i].limit
        val[i].limit = Double(timeBetween(start, Date(timeIntervalSince1970: stamp)))
      }
      self.fullSource[.Event]!.append((key, set, val, start, self.mainGraphSource[key] != nil, nil, toggleTracker.contains(key)))
    }
  }
  
  private func groupDataSet(_ set : BubbleChartDataSet) -> BubbleChartDataSet {
    guard !set.isEmpty else { return set }
    let startDate : Date = Date(timeIntervalSince1970: set.xMin)
    let newSet : BubbleChartDataSet = BubbleChartDataSet()
    var count : CGFloat = 1
    var lastEntree : BubbleChartDataEntry? = nil
    for entree in set.entries {
      let currentEntree : BubbleChartDataEntry = entree as! BubbleChartDataEntry
      let entrieDate = Date(timeIntervalSince1970: currentEntree.x)
      let xVal : Double = Double(timeBetween(startDate, entrieDate))
      currentEntree.x = xVal
      guard lastEntree != nil else {
        lastEntree = BubbleChartDataEntry(x: Double(xVal), y: currentEntree.y, size: currentEntree.size)
        continue
      }
      if lastEntree!.x == currentEntree.x {
        count += 1
        lastEntree!.size += currentEntree.size
        lastEntree!.y += 1
      } else {
        lastEntree!.size = lastEntree!.size/count
        newSet.append(lastEntree!)
        lastEntree = nil
        count = 1
      }
    }
    guard lastEntree != nil else { return newSet }
    lastEntree!.size = lastEntree!.size/count
    newSet.append(lastEntree!)
    return newSet
  }
  
  private func timeBetween(_ start : Date, _ end : Date) -> Int {
    return Calendar.current.dateComponents(
      [groupTime],
      from: start,
      to: end
    ).value(for: groupTime) ?? 0
  }
  
  private func graph() {
    self.graphView.xAxis.removeAllLimitLines()
    self.graphView.data = nil
    guard !self.mainGraphSource.isEmpty else { return }
    var startDate : Date = Date.distantFuture
    var endDate : Date = Date.distantPast
    self.mainGraphSource.forEach({ key, value in
      value.date < startDate ? startDate = value.date : ()
      value.date > endDate ? endDate = value.date : ()
    })
    let fullSpan : Double = Double(timeBetween(startDate, endDate))
    let data : BubbleChartData = BubbleChartData()
    for (key, value) in self.mainGraphSource {
      let referencePoint : Double = Double(timeBetween(startDate, value.date))
      let alteredSet : BubbleChartDataSet = BubbleChartDataSet()
      alteredSet.colors = value.set.colors
      value.set.entries.forEach({ e in
        if e.y > 0 {
          let entry : BubbleChartDataEntry = e as! BubbleChartDataEntry
          alteredSet.append(BubbleChartDataEntry.init(x: entry.x+referencePoint, y: entry.y, size: entry.size))
        }
      })
      alteredSet.label = key
      alteredSet.colors = value.set.colors
      alteredSet.setColor(Colors.Header.get())
      data.addDataSet(alteredSet)
      guard !value.limits.isEmpty else { continue }
      for line in value.limits {
        let xVal : Double = referencePoint+line.limit
        guard xVal >= 0 && xVal <= fullSpan else { continue }
        let alteredLine : ChartLimitLine = ChartLimitLine(limit: referencePoint+line.limit, label: key)
        alteredLine.lineColor = line.lineColor
        self.graphView.xAxis.addLimitLine(alteredLine)
      }
    }
    self.graphView.data = data
    while !graphView.isFullyZoomedOut {
      graphView.zoomOut()
    }
    self.graphView.animate(xAxisDuration: 0.3, yAxisDuration: 0.3)
  }
  
  @objc private func export() {
    if graphView.isEmpty() {
      MessagePopUp(self, "No information to graph", "Add some information to export a graph", nil).presentPopup()
      return
    }
    while !graphView.isFullyZoomedOut {
      graphView.zoomOut()
    }
    UIGraphicsBeginImageContext(self.view.frame.size)
    self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    let imageRef : CGImage = (image.cgImage?.cropping(to: graphView.frame))!
    let finalImage = UIImage(cgImage: imageRef)
    
    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: [finalImage],
      applicationActivities: nil
    )
    
    activityViewController.popoverPresentationController?.sourceView = self.view
    
    activityViewController.excludedActivityTypes = [
      UIActivity.ActivityType.airDrop,
      UIActivity.ActivityType.postToFacebook,
      UIActivity.ActivityType.postToTwitter,
      UIActivity.ActivityType.postToFlickr
    ]
    
    self.present(activityViewController, animated: true, completion: nil)
  }
  
}

extension GraphView : UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let data = self.tableSource[indexPath.row]
    let cell : GraphRow =  GraphRow()
    cell.set(data.question, data.dataSet, data.limitLines, data.shown, data.current, data.toggled)
    cell.indexPath = indexPath
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let curr = tableSource[indexPath.row]
    tableSource[indexPath.row] = (curr.question, curr.dataSet, curr.limitLines, curr.startDate, curr.shown, curr.current, !curr.toggled)
    (tableView.cellForRow(at: indexPath) as! GraphRow).toggle()
    UIView.animate(withDuration: 0.5) {
      tableView.reloadData()
    }
    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.tableSource[indexPath.row].toggled ? graphHeight.constant : UITableView.automaticDimension
  }
  
}

extension GraphView : buttonTapped {
  
  func showTapped(_ index: IndexPath) {
    let curr = tableSource[index.row]
    tableSource[index.row] = (curr.question, curr.dataSet, curr.limitLines, curr.startDate, !curr.shown, curr.current, curr.toggled)
    self.graphTableView.scrollToRow(at: index, at: .middle, animated: true)
    if !curr.shown {
      self.mainGraphSource[curr.question] = (curr.dataSet, curr.limitLines, curr.startDate)
    } else {
      self.mainGraphSource.removeValue(forKey: curr.question)
    }
    print("Data")
    print(self.mainGraphSource)
    self.updateTableData()
    self.changeSource(self.slidingButton.getCurrentText(), false)
    self.graph()
  }
  
  func currentTapped(_ index: IndexPath) {
    
  }
  
}

