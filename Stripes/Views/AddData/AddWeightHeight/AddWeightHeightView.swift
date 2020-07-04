//
//  AddWeightHeightView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/17/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class AddWeightHeightView : BaseDataView {
  
  lazy var verticalStack : UIStackView = {
    let vertical : UIStackView = UIStackView()
    vertical.translatesAutoresizingMaskIntoConstraints = false
    vertical.axis = .vertical
    vertical.alignment = .fill
    vertical.distribution = .equalSpacing
    vertical.spacing = StripesView.spacing/2
    return vertical
  }()
  
  private lazy var weightField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Weight"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  private lazy var heightField : UITextField = {
    let field : UITextField = UITextField()
    field.placeholder = "Height"
    field.textAlignment = .center
    field.backgroundColor = Colors.Text.get()
    field.textColor = UIColor.black
    field.delegate = self
    return field
  }()
  
  lazy var submitButton : UIButton = {
    let submit : UIButton = UIButton()
    submit.backgroundColor = Colors.Button.get()
    submit.setTitleColor(Colors.Text.get(), for: .normal)
    submit.setTitle("Submit", for: .normal)
    submit.addTarget(self, action: #selector(AddWeightHeightView.submit), for: .touchUpInside)
    return submit
  }()
  
  private var mostRecent : BMIData?
  
  override init(_ under: UIViewController) {
    super.init(under)
    self.height  = 0.3
    self.width = 0.8
    self.yoffset = -StripesView.spacing*3
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
    
    verticalStack.addArrangedSubview(weightField)
    verticalStack.addArrangedSubview(heightField)
    verticalStack.addArrangedSubview(submitButton)
    
    guard let stampedData = Store.instance.getSorted(types: [.BMI]).first, let bmiData = stampedData as? BMIData else {
      return
    }
    mostRecent = bmiData
    weightField.placeholder = "Weight: \(bmiData.weight)"
    heightField.placeholder = "Height: \(bmiData.feet)'\(bmiData.inches)"
  }

  @objc private func submit() {
    if weightField.text!.isEmpty && heightField.text!.isEmpty {
      self.dismissView(true){}
      return
    }
    let weight = Int(weightField.text!) ?? mostRecent?.weight ?? 0
    guard let
      heightString = heightField.text,
      heightString.components(separatedBy: CharacterSet.punctuationCharacters).count == 2 else {
        
      let data = BMIData(time: Int32(Date().timeIntervalSince1970), weight: weight, feet: mostRecent?.feet ?? 0, inches: mostRecent?.inches ?? 0)
      Store.instance.add(data)
      self.dismissView(true) { self.escapeFunction!() }
      return
    }
    let split : [String] = heightString.components(separatedBy: CharacterSet.punctuationCharacters)
    let feet = Int(split.first!) ?? mostRecent?.feet ?? 0
    let inches = Int(split.last!) ?? mostRecent?.inches ?? 0
    print(split, feet, inches)
    let data = BMIData(time: Int32(Date().timeIntervalSince1970), weight: weight, feet: feet, inches: inches)
    Store.instance.add(data)
    self.dismissView(true) { self.escapeFunction!() }
  }
  
}

extension AddWeightHeightView : UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var set = CharacterSet.urlPathAllowed
    set.insert(charactersIn: "0123456789'")
    return string.rangeOfCharacter(from: set.inverted) == nil
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
