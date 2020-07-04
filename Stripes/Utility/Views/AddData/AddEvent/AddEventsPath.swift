//
//  AddEventsPath.swift
//  Stripes
//
//  Created by Dylan Baker on 5/16/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit
import CoreLocation

class AddEventsPath : TableDataView {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.top = "Event Type"
    self.dataSource = self.getTableTypeData()
    self.tableView.register(eventCell.self, forCellReuseIdentifier: "EventCell")
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let type : eventType = eventType(rawValue: self.dataForIndex(indexPath.row).mainText)!
    switch type {
      case .dietaryChange:
        self.dismissView(true) {
          dietaryChangeView(self.parentView).present(true) {
            self.escapeFunction!()
          }
        }
        return
      case .moved:
        self.dismissView(true) {
          movedView(self.parentView).present(true) {
            self.escapeFunction!()
          }
        }
        return
      case .psychiatricHospitalization:
        self.dismissView(true) {
          psychiatricView(self.parentView).present(true) {
            self.escapeFunction!()
          }
        }
        return
      
      case .medicalIntervention: return
        self.dismissView(true) {
          interventionView(self.parentView).present(true) {
            self.escapeFunction!()
          }
        }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell : eventCell = eventCell(self.dataForIndex(indexPath.row).mainText)
    return cell
  }
  
  private func getTableTypeData()->[tableData] {
    return eventType.getOrdered().map({ type in
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

class eventView: BaseDataView {
  
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

extension eventView : UITextViewDelegate, UITextFieldDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

private class dietaryChangeView: eventView {
  
  private lazy var nutrientField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Nutrient"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  private lazy var addRemoveButton : UISegmentedControl = {
    let segment : UISegmentedControl = UISegmentedControl.init(items: ["Added", "Removed"])
    segment.backgroundColor = Colors.Header.get()
    if #available(iOS 13.0, *) {
      segment.selectedSegmentTintColor = Colors.Button.get()
      segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Colors.Text.get()], for: .normal)
    } else {
      segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Colors.Button.get()], for: .normal)
    }
    segment.setTitle("Added", forSegmentAt: 0)
    segment.setTitle("Removed", forSegmentAt: 1)
    segment.selectedSegmentIndex = 0
    
    return segment
  }()
  
  override init(_ under : UIViewController) {
    super.init(under)
    self.height = 0.4
    self.width = 0.8
    self.yoffset = -StripesView.spacing*3
    submitButton.addTarget(self, action: #selector(dietaryChangeView.submit), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    verticalStack.addArrangedSubview(nutrientField)
    verticalStack.addArrangedSubview(addRemoveButton)
    verticalStack.addArrangedSubview(submitButton)
    
  }
  
  @objc private func submit() {
    guard !nutrientField.text!.isEmpty else {
      self.dismissView(true){
        MessagePopUp.init(self.parentView, "Warning", "Unable to add dietary change", nil).presentPopup()
      }
      return
    }
    self.dismissView(true) {
      let action : String = self.addRemoveButton.titleForSegment(at: self.addRemoveButton.selectedSegmentIndex)!
      let desc : String = "\(action) \(self.nutrientField.text!) \(action == "Added" ? "to" : "from") diet"
      let data = EventData(time: Int32(Date().timeIntervalSince1970), type: eventType.dietaryChange.rawValue, desc: [desc])
      Store.instance.add(data)
      self.escapeFunction!()
    }
  }
  
}

private class movedView : eventView, CLLocationManagerDelegate {
  
  private lazy var cityField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "City"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  private lazy var stateField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "State"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  private lazy var countryField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Country"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  let location : CLLocationManager = CLLocationManager()
  
  override init(_ under : UIViewController) {
    super.init(under)
    self.height = 0.4
    self.width = 0.8
    self.yoffset = -StripesView.spacing*3
    location.delegate = self
    submitButton.addTarget(self, action: #selector(movedView.submit), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    verticalStack.addArrangedSubview(cityField)
    verticalStack.addArrangedSubview(stateField)
    verticalStack.addArrangedSubview(countryField)
    verticalStack.addArrangedSubview(submitButton)
    
    let status = CLLocationManager.authorizationStatus()
    if status != .denied {
      location.requestWhenInUseAuthorization()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      location.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.fillLocation(manager.location!)
  }
  
  private func fillLocation(_ loc : CLLocation) {
    print("Ran")
    loc.fetchCityAndCountry() { city, state, country, err in
      guard err == nil else {
        return
      }
      self.cityField.text = city ?? ""
      self.stateField.text = state ?? ""
      self.countryField.text = country ?? ""
      self.location.stopUpdatingLocation()
    }
  }
  
  @objc private func submit() {
    guard !cityField.text!.isEmpty && !stateField.text!.isEmpty && !countryField.text!.isEmpty else {
      self.dismissView(true){
        MessagePopUp.init(self.parentView, "Warning", "Unable to add location change", nil).presentPopup()
      }
      return
    }
    self.dismissView(true){
      let data = EventData(time: Int32(Date().timeIntervalSince1970), type: eventType.moved.rawValue, desc: [self.cityField.text!, self.stateField.text!, self.countryField.text!])
      Store.instance.add(data)
      self.escapeFunction!()
    }
  }
  
}

private class psychiatricView : eventView {
  
  private lazy var instituteField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Institute"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  private lazy var reasonLabel : UILabel = {
    let reason : UILabel = UILabel()
    reason.text = "Reason for visit:"
    reason.textAlignment = .center
    reason.textColor = UIColor.black
    return reason
  }()
  
  private lazy var reasonView : UITextView = {
    [unowned self] in
    let reason : UITextView = UITextView()
    reason.showsHorizontalScrollIndicator = false
    reason.textColor = UIColor.black
    reason.heightAnchor.constraint(equalToConstant: StripesView.spacing*6).isActive = true
    reason.backgroundColor = Colors.Text.get()
    reason.delegate = self
    return reason
  }()
  
  override init(_ under : UIViewController) {
    super.init(under)
    self.height = 0.5
    self.width = 0.8
    self.yoffset = -StripesView.spacing*3
    submitButton.addTarget(self, action: #selector(psychiatricView.submit), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    verticalStack.distribution = .equalSpacing
    verticalStack.spacing = 0
    submitButton.heightAnchor.constraint(equalToConstant: StripesView.spacing*2).isActive = true
    
    verticalStack.addArrangedSubview(instituteField)
    verticalStack.addArrangedSubview(reasonLabel)
    verticalStack.addArrangedSubview(reasonView)
    verticalStack.addArrangedSubview(submitButton)
  }
  
  @objc private func submit() {
    guard !instituteField.text!.isEmpty && !reasonView.text.isEmpty else {
      self.dismissView(true){
        MessagePopUp.init(self.parentView, "Warning", "Unable to add psychiatric hospitalization", nil).presentPopup()
      }
      return
    }
    self.dismissView(true){
      let data = EventData(time: Int32(Date().timeIntervalSince1970), type: eventType.psychiatricHospitalization.rawValue, desc: [self.instituteField.text!, self.reasonView.text,])
      Store.instance.add(data)
      self.escapeFunction!()
    }
  }
}

private class interventionView : eventView {
  
  private lazy var typeField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Type"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  private lazy var providerField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Provider"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  override init(_ under : UIViewController) {
    super.init(under)
    self.height = 0.3
    self.width = 0.8
    self.yoffset = -StripesView.spacing*3
    submitButton.addTarget(self, action: #selector(interventionView.submit), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    verticalStack.distribution = .equalSpacing
    verticalStack.spacing = 0
    submitButton.heightAnchor.constraint(equalToConstant: StripesView.spacing*2).isActive = true
    
    verticalStack.addArrangedSubview(typeField)
    verticalStack.addArrangedSubview(providerField)
    verticalStack.addArrangedSubview(submitButton)
  }
  
  @objc private func submit() {
    guard !typeField.text!.isEmpty && !providerField.text!.isEmpty else {
      self.dismissView(true){
        MessagePopUp.init(self.parentView, "Warning", "Unable to add medical intervention", nil).presentPopup()
      }
      return
    }
    self.dismissView(true){
      let data = EventData(time: Int32(Date().timeIntervalSince1970), type: eventType.medicalIntervention.rawValue, desc: [self.typeField.text!, self.providerField.text!])
      Store.instance.add(data)
      self.escapeFunction!()
    }
  }
}
