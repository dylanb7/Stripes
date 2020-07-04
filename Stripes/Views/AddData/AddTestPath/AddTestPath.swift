//
//  AddTestPath.swift
//  Stripes
//
//  Created by Dylan Baker on 5/21/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class AddTestPath : TableDataView {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.top = "Test Type"
    self.dataSource = self.getTableTypeData()
    self.tableView.register(eventCell.self, forCellReuseIdentifier: "EventCell")
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let type : testType = testType(rawValue: self.dataForIndex(indexPath.row).mainText)!
    switch type {
      case .blueDye:
        return
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell : eventCell = eventCell(self.dataForIndex(indexPath.row).mainText)
    return cell
  }
  
  private func getTableTypeData()->[tableData] {
    return testType.getOrdered().map({ type in
      return tableData(mainText: type.rawValue, image: nil, selectable: false, hasScale: false)
      })
  }
  
}

private class eventCell: UITableViewCell {
  
  private lazy var mainText : UILabel = {
    [unowned self] in
    let main : UILabel = UILabel()
    main.numberOfLines = 0
    main.textAlignment = .center
    main.contentMode = .top
    main.textColor = UIColor.black
    main.fitTextToBounds()
    main.translatesAutoresizingMaskIntoConstraints = false
    return main
  }()
  
  init(_ text : String) {
    super.init(style: .default, reuseIdentifier: "EventCell")
    self.backgroundColor = UIColor.white
    self.selectionStyle = .none
    self.contentView.addSubview(mainText)
    
    NSLayoutConstraint.activate([
      mainText.topAnchor.constraint(equalTo: contentView.topAnchor, constant: StripesView.spacing),
      mainText.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: StripesView.spacing),
      mainText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -StripesView.spacing),
      mainText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -StripesView.spacing),
    ])
    
    mainText.text = text
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

class testView : BaseDataView {
  
  lazy var verticalStack : UIStackView = {
    let vertical : UIStackView = UIStackView()
    vertical.translatesAutoresizingMaskIntoConstraints = false
    vertical.axis = .vertical
    vertical.alignment = .fill
    vertical.distribution = .fillProportionally
    vertical.spacing = StripesView.spacing*2
    return vertical
  }()
  
  lazy var submitButton : UIButton = {
    let submit : UIButton = UIButton()
    submit.backgroundColor = Colors.Button.get()
    submit.setTitleColor(Colors.Text.get(), for: .normal)
    submit.setTitle("Submit", for: .normal)
    return submit
  }()
  
  override init(_ under : UIViewController) {
    super.init(under)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(verticalStack)
    
    NSLayoutConstraint.activate([
      verticalStack.topAnchor.constraint(equalTo: self.view.topAnchor, constant: StripesView.spacing),
      verticalStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: StripesView.spacing),
      verticalStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -StripesView.spacing),
      verticalStack.bottomAnchor.constraint(equalTo: self.dismissButton.topAnchor, constant: -StripesView.spacing),
    ])
  }
  
}

class blueDyeTest : testView {
  
  override init(_ under: UIViewController) {
    super.init(under)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
