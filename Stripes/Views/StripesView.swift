//
//  ViewController.swift
//  Stripes
//
//  Created by Dylan Baker on 3/4/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class StripesView: UIViewController {

  private var currentUsers : [String] = Store.instance.getUsers() {
    didSet {
      if currentUsers.isEmpty {
        toggleAll(hidden: true)
      } else {
        toggleAll(hidden: false)
      }
    }
  }
  
  static var spacing : CGFloat = UIScreen.main.bounds.height*0.025
  
  private lazy var topStack : UIStackView = {
    let stack : UIStackView = UIStackView(arrangedSubviews: [
      addButton,
      current,
      editButton
    ])
    stack.axis = .horizontal
    stack.distribution = UIStackView.Distribution.equalSpacing
    stack.alignment = .center
    stack.spacing = StripesView.spacing
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()
  
  private lazy var current : UIButton = {
    let curr : UIButton = UIButton(type: .custom)
    curr.backgroundColor = Colors.Button.get()
    curr.roundCorners(10)
    curr.layer.borderWidth = 2.0
    curr.layer.borderColor = Colors.HeaderText.get().cgColor
    if let user = Store.instance.getCurrent() {
      curr.setTitle(user.username, for: .normal)
    } else {
      curr.setTitle("Add User", for: .normal)
    }
    curr.addTarget(self, action: #selector(StripesView.presentUserSelection), for: .touchUpInside)
    return curr
  }()
  
  private lazy var addButton : UIButton = {
    let add : UIButton = UIButton(frame: CGRect.zero)
    add.setImage(UIImage(named: "add")!.withRenderingMode(.alwaysTemplate), for: .normal)
    add.tintColor = Colors.Button.get()
    add.addTarget(self, action: #selector(StripesView.addUser), for: .touchUpInside)
    return add
  }()
  
  private lazy var editButton : UIButton = {
    let edit : UIButton = UIButton(frame: CGRect.zero)
    edit.setImage(UIImage(named: "edit")!.withRenderingMode(.alwaysTemplate), for: .normal)
    edit.frame = CGRect.zero
    edit.tintColor = Colors.Button.get()
    edit.addTarget(self, action: #selector(StripesView.editUser), for: .touchUpInside)
    return edit
  }()
  
  private lazy var slidingButton : SlidingButton = {
    [unowned self] in
    let sortedKeys : [String] = Array(self.buttonTypes.keys.sorted())
    let button = SlidingButton(CGRect.zero, sortedKeys, 0)
    button.backgroundColor = Colors.Button.get()
    button.textColor = Colors.Text.get()
    button.roundCorners(20)
    button.layer.borderWidth = 3.0
    button.layer.borderColor = Colors.HeaderText.get().cgColor
    button.arrowColor = Colors.HeaderText.get()
    button.addAction(sortedKeys[0]) {
      AddSymptomsPath(self).present(true) {
        self.reloadRecents()
      }
    }
    button.addAction(sortedKeys[1]) {
      AddEventsPath(self).present(true) {
        self.reloadRecents()
      }
    }
    button.addAction(sortedKeys[2]) {
      AddTestPath(self).present(true) {
        self.reloadRecents()
      }
    }
    button.addAction(sortedKeys[3]) {
      AddWeightHeightView(self).present(true) {
        self.reloadRecents()
      }
    }
    button.addSwitchFunction({text in
      self.reloadRecents()
      self.toggleViewAll()
    })
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  
  private lazy var noCurrentLabel : UILabel = {
    let noCurrent : UILabel = UILabel(frame: CGRect.zero)
    noCurrent.text = "Add First User"
    noCurrent.backgroundColor = Colors.Header.get()
    noCurrent.textColor = Colors.Text.get()
    noCurrent.textAlignment = .center
    noCurrent.roundCorners(15)
    noCurrent.isHidden = true
    noCurrent.translatesAutoresizingMaskIntoConstraints = false
    return noCurrent
  }()
  
  private lazy var recentLogs : RecentsView = {
    let recents : RecentsView = RecentsView()
    recents.backgroundColor = UIColor.white
    recents.translatesAutoresizingMaskIntoConstraints = false
    return recents
  }()
  
  private lazy var viewAllButton : UIButton = {
    let viewAll : UIButton = UIButton(type: .custom)
    viewAll.backgroundColor = Colors.Button.get()
    viewAll.roundCorners(15)
    viewAll.setTitleColor(Colors.Text.get(), for: .normal)
    viewAll.setTitle("View/Edit All", for: .normal)
    viewAll.translatesAutoresizingMaskIntoConstraints = false
    viewAll.addTarget(self, action: #selector(StripesView.viewAll), for: .touchUpInside)
    return viewAll
  }()
  
  private weak var currentPop : PopUp?
  
  private let buttonTypes : [String : dataType] = ["Add Symptoms" : .User, "Lifestyle Changes" : .Event, "Perform Test" : .Test, "Weight & Height" : .BMI]
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.addTopButtons()
    self.view.addSubview(slidingButton)
       
    NSLayoutConstraint.activate([
      slidingButton.topAnchor.constraint(equalTo: current.bottomAnchor, constant: StripesView.spacing),
      slidingButton.leadingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -StripesView.spacing*2),
      slidingButton.trailingAnchor.constraint(equalTo: editButton.trailingAnchor, constant:  StripesView.spacing*2),
      slidingButton.heightAnchor.constraint(equalToConstant: StripesView.spacing*4)
    ])
    
    self.view.addSubview(viewAllButton)
    
    NSLayoutConstraint.activate([
      viewAllButton.heightAnchor.constraint(equalToConstant: StripesView.spacing*2),
      viewAllButton.leadingAnchor.constraint(equalTo: addButton.leadingAnchor),
      viewAllButton.trailingAnchor.constraint(equalTo: editButton.trailingAnchor)
    ])
    
    self.view.addSubview(recentLogs)
    
    NSLayoutConstraint.activate([
      recentLogs.topAnchor.constraint(equalTo: slidingButton.bottomAnchor, constant: StripesView.spacing*2),
      recentLogs.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      recentLogs.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      recentLogs.bottomAnchor.constraint(equalTo: viewAllButton.topAnchor, constant: -StripesView.spacing)
    ])
    
    self.view.addSubview(noCurrentLabel)
    
    NSLayoutConstraint.activate([
      noCurrentLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      noCurrentLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      noCurrentLabel.widthAnchor.constraint(equalToConstant: StripesView.spacing*12),
      noCurrentLabel.heightAnchor.constraint(equalToConstant: StripesView.spacing*4)
    ])
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    topStack.topAnchor.constraint(equalTo: (self.navigationController?.navigationBar.bottomAnchor)!, constant: StripesView.spacing).isActive = true
    viewAllButton.bottomAnchor.constraint(equalTo: tabBarController!.tabBar.topAnchor, constant: -StripesView.spacing).isActive = true
    
    noCurrentLabel.fitTextToBounds()
    
    slidingButton.reloadGraphics()
    
    recentLogs.set(self.buttonTypes[slidingButton.getCurrentText()]!)
    
    self.toggleViewAll()
    if currentUsers.isEmpty {
      toggleAll(hidden: true)
    }
  }
  
  private func toggleAll(hidden : Bool) {
    self.slidingButton.isHidden = hidden
    self.recentLogs.isHidden = hidden
    self.viewAllButton.isHidden = hidden
    self.noCurrentLabel.isHidden = !hidden
  }
  
  private func toggleViewAll() {
    self.viewAllButton.isHidden = Store.instance.get(type: self.buttonTypes[self.slidingButton.getCurrentText()]!).isEmpty
  }
  
  private func reloadRecents() {
    self.recentLogs.set(self.buttonTypes[slidingButton.getCurrentText()]!)
    self.viewAllButton.isHidden = self.recentLogs.length == 0
  }
  
  @objc private func viewAll() {
    self.present(ViewAllTable(self.buttonTypes[slidingButton.getCurrentText()]!), animated: true) {
      self.reloadRecents()
    }
   }
  
}





extension StripesView : PopDelegate {
  
  private func addTopButtons(){
    
    let sideButtonSize : CGFloat = StripesView.spacing*1.5
    
    topStack.heightAnchor.constraint(equalToConstant: sideButtonSize).isActive = true
    
    NSLayoutConstraint.activate([
      current.widthAnchor.constraint(equalToConstant: StripesView.spacing*8),
      current.heightAnchor.constraint(equalToConstant: sideButtonSize),
      addButton.widthAnchor.constraint(equalToConstant: sideButtonSize),
      editButton.widthAnchor.constraint(equalToConstant: sideButtonSize)
    ])
    
    self.view.addSubview(topStack)
    NSLayoutConstraint.activate([
      topStack.heightAnchor.constraint(equalToConstant: sideButtonSize),
      topStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    ])
    
  }
  
  
  @objc private func presentUserSelection() {
    if currentPop != nil { return }
    let users : [String] = Store.instance.getUsers()
    if users.isEmpty {
      self.addUser()
      return
    }
    var index = -1
    if let curr = Store.instance.getCurrent() {
      for i in 0..<users.count {
        if users[i] == curr.username {
          index = i
          break
        }
      }
    }
    ButtonPopUp(self, "Select a user", Store.instance.getUsers(), index, self, selectFunction(_:)).presentPopup()
  }
  
  @objc private func addUser() {
    TextPopUp(self, "Add a user", ["Username", "Name", "Gender", "DOB(i.e. 10/24/1999)"], self, self.parseUser(_:)).presentPopup()
  }
  
  @objc private func editUser() {
    guard var user = Store.instance.getCurrent() else {
      MessagePopUp(self, "No User", "Add a user to edit", self).presentPopup()
      return
    }
    let popString : String = "Edit \(user.username)"
    let deleteString : String = "Delete User"
    ButtonPopUp(self, "Edit User", [popString, deleteString], nil, self, { res in
      if res == deleteString {
        let _ = Store.instance.removeUser(name: user.username)
        self.currentUsers = Store.instance.getUsers()
        if self.currentUsers.isEmpty {
          self.current.setTitle("Add User", for: .normal)
        }
      } else {
        let info : UserInfo = user.info
        TextPopUp(self, "Edit \(user.username)", [user.username, info.name, info.gender, info.dob.toDate().cleanString(false)], self, { res in
          let username = res[0]
          let name = res[1]
          let gender = res[2]
          let date = res[3].isEmpty ? -1 : self.parseDate(res[3])
          user.username = username.isEmpty ? user.username : username
          user.info.name = name.isEmpty ? user.info.name : name
          user.info.gender = gender.isEmpty ? user.info.gender : gender
          user.info.dob = date == -1 ? user.info.dob : date
          if !Store.instance.editUser(user: user) {
            self.currentUsers = Store.instance.getUsers()
          }
        }).presentPopup()
      }
    }).presentPopup()
  }
  
  private func parseUser(_ inputs : [String]) {
    let username : String = inputs[0]
    let name : String = inputs[1]
    let gender : String = inputs[2]
    let date : Int32 = parseDate(inputs[3])
    if username.isEmpty || name.isEmpty || gender.isEmpty || date == -1 {
      MessagePopUp(self,
                   "Failed",
                   "Unable to add user: \(username.isEmpty ? "BLANK" : username) with name: \(name.isEmpty ? "BLANK" : name) and gender: \(gender.isEmpty ? "BLANK" : gender) born on: \(inputs[3].isEmpty ? "BLANK" : inputs[3])",
                    self
      ).presentPopup()
      return
    }
    let info : UserInfo = UserInfo(name: inputs[1], gender: inputs[2], dob: date)
    let user : User = User(username: inputs[0], info: info, bmi: [], events: [], data: [], tests: [])
    if(!Store.instance.addUser(user: user)) {
      MessagePopUp(self,
                   "Failed",
                   "Unable to add user",
                    self
      ).presentPopup()
    } else {
      self.currentUsers = Store.instance.getUsers()
      if currentUsers.count == 1 && Store.instance.makeCurrent(username: user.username)  {
        current.setTitle(user.username, for: .normal)
        self.reloadRecents()
      }
    }
  }
  
  private func parseDate(_ date: String)->Int32{
    let dateString : String = date.filter({ char in
      return char != " "
    })
    let dateComponents : [Substring] = dateString.split(separator: "/")
    if dateComponents.count != 3 { return -1 }
    var numComponents : [Int] = []
    for var component in dateComponents {
      while component.first != nil && component.first == "0" {
        component.remove(at: component.startIndex)
      }
      guard let val : Int = Int(component) else { return -1 }
      numComponents.append(val)
    }
    let calendar : Calendar = Calendar.current
    let dateComp : DateComponents = DateComponents(calendar: calendar, year: numComponents[2], month: numComponents[0], day: numComponents[1])
    guard let date = calendar.date(from: dateComp) else {
      return -1
    }
    let timeValue = date.timeIntervalSince1970
    let max : Double = 2147483647
    return timeValue > max ? -1 : timeValue < -max ? -1 : Int32(date.timeIntervalSince1970)
  }
  
  private func selectFunction(_ text : String) {
    guard text != "" else {
      return
    }
    if Store.instance.makeCurrent(username: text) {
      current.setTitle(text, for: .normal)
      self.reloadRecents()
    }
  }
  
  func didDismiss(_ popUp: PopUp) {
    self.currentPop = nil
  }
  
  func didLoad(_ popUp: PopUp) {
    self.currentPop = popUp
  }

}

