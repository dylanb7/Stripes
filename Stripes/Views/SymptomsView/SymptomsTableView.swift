//
//  SymptomsTableView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/8/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class SymptomsTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  lazy var tableView : UITableView = {
    [unowned self] in
    let table : UITableView = UITableView()
    table.delegate = self
    table.dataSource = self
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  }()
  
  private let spacing : CGFloat = StripesView.spacing
  
  private var data : [Question] = [] {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  private var starter : [Type] = Type.getOrdered()
  
  private var isStart : Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.frame = CGRect.zero
    self.view.translatesAutoresizingMaskIntoConstraints = false
    self.view.backgroundColor = Colors.Background.get()
    self.view.roundCorners(20)
    self.view.layer.shadowColor = UIColor.gray.cgColor
    self.view.layer.shadowRadius = 20
    self.view.layer.shadowOffset = CGSize.zero
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.view.constrainToSuperview(withSpacing: spacing*2)
    
    //self.view.addSubview(tableView)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isStart ? starter.count : data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard !isStart else {
      let cell = UITableViewCell()
      cell.textLabel?.text = starter[indexPath.row].rawValue
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard !isStart else {
      self.isStart = false
      self.data = QuestionPath().getQuestions(starter[indexPath.row])
      return
    }
    
  }
  
  
  
}

