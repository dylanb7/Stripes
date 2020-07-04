//
//  TableDataView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/9/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

struct tableData {
  var mainText : String
  var image : UIImage?
  var selectable : Bool
  var hasScale : Bool
}

class TableDataView: BaseDataView {
  
  lazy var tableView : UITableView = {
    [unowned self] in
    let table : UITableView = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.dataSource = self
    table.delegate = self
    table.alpha = 0.0
    table.backgroundColor = UIColor.white
    table.rowHeight = UITableView.automaticDimension
    table.showsHorizontalScrollIndicator = false
    table.separatorInset = .zero
    table.estimatedRowHeight = 600
    return table
  }()
  
  private lazy var titleLabel : UILabel = {
    let title : UILabel = UILabel()
    title.translatesAutoresizingMaskIntoConstraints = false
    title.text = top
    title.textAlignment = .center
    title.backgroundColor = Colors.Header.get()
    title.textColor = Colors.Text.get()
    title.roundCorners(10)
    title.alpha = 0.0
    title.contentMode = .center
    return title
  }()
  
  var top : String! {
    didSet {
      if view.superview != nil {
        titleLabel.text = top
        titleLabel.fitTextToBounds()
      }
    }
  }
  
  var dataSource : [tableData] = [] {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: spacing),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
      titleLabel.heightAnchor.constraint(equalToConstant: spacing*3)
    ])
    
    titleLabel.fitTextToBounds()
    
    self.view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -spacing),
      tableView.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -spacing)
    ])
    
  }
  
  func setData(_ top : String, _ data : [tableData]){
    UIView.animate(withDuration: 0.3, animations: {
      self.titleLabel.alpha = 0.0
      self.tableView.alpha = 0.0
    }, completion: { res in
      self.top = top
      self.dataSource = data
      UIView.animate(withDuration: 0.3) {
        self.titleLabel.alpha = 1.0
        self.tableView.alpha = 1.0
      }
    })
  }
  
  func configureCellForRow(_ data : tableData) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = data.mainText
    return cell
  }
  
  func dataForIndex(_ index : Int)->tableData{
    return self.dataSource[index]
  }
  
}

extension TableDataView : UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return self.configureCellForRow(dataSource[indexPath.row])
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
  }
  
}

extension Array where Element == tableData {
  
  mutating func addContinueElement()->[tableData]{
    self.append(tableData(mainText: "Continue", image: nil, selectable: false, hasScale: false))
    return self
  }
  
}
