//
//  SubmitView.swift
//  Stripes
//
//  Created by Dylan Baker on 5/12/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class SubmitView: BaseDataView {
  
  private lazy var scrollView : UIScrollView = {
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    scroll.showsVerticalScrollIndicator = false
    scroll.showsHorizontalScrollIndicator = false
    return scroll
  }()
  
  private lazy var verticalStack : UIStackView = {
    [unowned self] in
    let vertical : UIStackView = UIStackView()
    vertical.translatesAutoresizingMaskIntoConstraints = false
    vertical.axis = .vertical
    vertical.alignment = .fill
    vertical.distribution = .equalSpacing
    vertical.spacing = self.spacing
    return vertical
  }()
  
  private lazy var activitiesLabel : UILabel = {
    [unowned self] in
    let activities = UILabel()
    activities.text = "\(self.missedQuestion!.text)?"
    activities.numberOfLines = 0
    activities.textColor = UIColor.black
    activities.textAlignment = .center
    return activities
  }()
  
  private lazy var activitiesButton : UISegmentedControl = {
    let segment : UISegmentedControl = UISegmentedControl.init(items: ["Yes", "No"])
    segment.backgroundColor = Colors.Header.get()
    if #available(iOS 13.0, *) {
      segment.selectedSegmentTintColor = Colors.Button.get()
      segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Colors.Text.get()], for: .normal)
    } else {
      segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Colors.Button.get()], for: .normal)
    }
    segment.setTitle("Yes", forSegmentAt: 0)
    segment.setTitle("No", forSegmentAt: 1)
    segment.selectedSegmentIndex = 1
    
    return segment
  }()
  
  private lazy var descriptionLabel : UILabel = {
    let label : UILabel = UILabel()
    label.textAlignment = .center
    label.textColor = UIColor.black
    label.text = "Describe your experience"
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var descriptionView : UITextView = {
    [unowned self] in
    let description : UITextView = UITextView()
    description.showsHorizontalScrollIndicator = false
    description.heightAnchor.constraint(equalToConstant: self.spacing*7).isActive = true
    description.textColor = UIColor.black
    description.backgroundColor = Colors.Text.get()
    description.delegate = self
    return description
  }()
  
  private lazy var addImageButton : UIButton = {
    [unowned self] in
    let addImage : UIButton = UIButton()
    addImage.backgroundColor = Colors.Button.get()
    addImage.setTitleColor(Colors.Text.get(), for: .normal)
    addImage.setTitle("Add Image", for: .normal)
    self.imageHeightConstraint = NSLayoutConstraint(item: addImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.spacing*5)
    self.imageHeightConstraint!.isActive = true
    addImage.roundCorners(10)
    addImage.addTarget(self, action: #selector(SubmitView.pickImage), for: .touchUpInside)
    return addImage
  }()
  
  private lazy var occuranceLabel : UILabel = {
    let label : UILabel = UILabel()
    label.textAlignment = .center
    label.text = "Occurrence: "
    label.textColor = UIColor.black
    label.numberOfLines = 1
    return label
  }()
  
  private lazy var instances : UITextField = {
    let field : UITextField = UITextField()
    field.delegate = self
    field.text = "1"
    field.textAlignment = .center
    field.backgroundColor = UIColor.white
    field.textColor = UIColor.black 
    return field
  }()
  
  private lazy var intervalLabel : UILabel = {
    let label : UILabel = UILabel()
    label.textAlignment = .center
    label.text = "Frequency: "
    label.numberOfLines = 1
    label.textColor = UIColor.black
    return label
  }()
  
  private lazy var intervalPicker : UIPickerView = {
    let picker : UIPickerView = UIPickerView()
    picker.delegate = self
    picker.dataSource = self
    return picker
  }()
  
  private lazy var frequencyHStack : UIStackView = {
    let freq : UIStackView = UIStackView()
    freq.axis = .horizontal
    freq.spacing = 0
    freq.heightAnchor.constraint(equalToConstant: spacing*4).isActive = true
    freq.distribution = .equalCentering
    freq.isHidden = true
    return freq
  }()
  
  private lazy var submitButton : UIButton = {
    let submit : UIButton = UIButton()
    submit.backgroundColor = Colors.Button.get()
    submit.setTitleColor(Colors.Text.get(), for: .normal)
    submit.setTitle("Submit Entry", for: .normal)
    submit.addTarget(self, action: #selector(SubmitView.submit), for: .touchUpInside)
    return submit
  }()
  
  private let pickerDataSource : [String] = ["Hourly", "Twice a day", "Daily", "Every other day", "Weekly"]
  
  private var currentImage : UIImage? {
    didSet {
      let size = currentImage!.size
      let aspect = size.height/size.width
      let prefferedHeight = addImageButton.frame.width*aspect
      let heightAnchor = prefferedHeight < self.spacing*4 ? self.spacing*4 : prefferedHeight > self.spacing*12 ? self.spacing*12 : prefferedHeight
      self.imageHeightConstraint?.constant = heightAnchor
      self.verticalStack.setNeedsLayout()
      self.verticalStack.setNeedsDisplay()
      self.addImageButton.setImage(currentImage, for: .normal)
    }
  }
  
  private var imageHeightConstraint : NSLayoutConstraint?
  
  private let observer : QuestionObserver!
  
  private let missedQuestion : Question?
  
  init(_ under: UIViewController, _ observer : QuestionObserver) {
    self.observer = observer
    self.missedQuestion = observer.getType() == .OTHER ? nil : QuestionPath.missedQuestions[observer.getType()]!
    super.init(under)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(scrollView)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: spacing),
      scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: spacing),
      scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -spacing),
      scrollView.bottomAnchor.constraint(equalTo: self.dismissButton.topAnchor, constant: -spacing)
    ])
    
    scrollView.addSubview(verticalStack)
    
    NSLayoutConstraint.activate([
      verticalStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
      verticalStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      verticalStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      verticalStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
    ])
    
    NSLayoutConstraint(item: verticalStack, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0).isActive = true
    
    if let _ = missedQuestion {
      verticalStack.addArrangedSubview(activitiesLabel)
      verticalStack.addArrangedSubview(activitiesButton)
      verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    }
    
    verticalStack.addArrangedSubview(descriptionLabel)
    verticalStack.addArrangedSubview(descriptionView)
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    verticalStack.addArrangedSubview(addImageButton)
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    let occurance : UIStackView = UIStackView()
    occurance.axis = .horizontal
    occurance.spacing = 0
    occurance.distribution = .fillEqually
    occurance.addArrangedSubview(occuranceLabel)
    occurance.addArrangedSubview(instances)
    
    frequencyHStack.addArrangedSubview(intervalLabel)
    frequencyHStack.addArrangedSubview(intervalPicker)
    
    verticalStack.addArrangedSubview(occurance)
    verticalStack.addArrangedSubview(frequencyHStack)
    verticalStack.addArrangedSubview(UIView.getSeparator(width: false, withColor: UIColor.black))
    
    verticalStack.addArrangedSubview(submitButton)
  }
  
  @objc private func pickImage() {
    ImagePickerManager().pickImage(self) { image in
      self.currentImage = image
      self.view.updateConstraints()
    }
  }
  
  @objc private func submit() {
    if let question = missedQuestion, activitiesButton.selectedSegmentIndex == 0 {
      let response = Response(question: question, severity: nil, location: nil)
      observer.add([response])
    }
    self.dismissView(true) {
      let num = Int(self.instances.text!)!
      if num > 1 {
        var interval : TimeInterval = 60*60
        switch self.pickerDataSource[self.intervalPicker.selectedRow(inComponent: 0)] {
          case "Hourly": break
          case "Twice a day": interval = interval*12; break
          case "Daily": interval = interval*24; break
          case "Every other day": interval = interval*48; break
          default: interval = interval*24*7
        }
        self.observer.submit(self.descriptionView.text, self.currentImage, interval, num)
        self.escapeFunction!()
        return
      }
      self.observer.submit(self.descriptionView.text, self.currentImage, nil, 1)
      self.escapeFunction!()
    }
  }
  
}

extension SubmitView : UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let text = textField.text else { return }
    if text == "0" || text == "" {
      textField.text = "1"
      frequencyHStack.isHidden = true
    } else if text != "1" {
      frequencyHStack.isHidden = false
    } else {
      frequencyHStack.isHidden = true
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

extension SubmitView : UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
  
}

extension SubmitView : UIPickerViewDelegate, UIPickerViewDataSource {
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerDataSource[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerDataSource.count
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
}
