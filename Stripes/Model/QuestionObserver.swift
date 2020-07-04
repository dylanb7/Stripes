//
//  QuestionObserver.swift
//  Stripes
//
//  Created by Dylan Baker on 3/10/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

struct Response : Codable {
  var question : Question
  var severity : CGFloat?
  var location : String?
}

class QuestionObserver {
  
  private var responses : [Response]
  
  private var type : symptomType
  
  init(_ type : symptomType) {
    self.type = type
    self.responses = []
  }
  
  func add(_ response : [Response]) {
    self.responses.append(contentsOf: response)
  }
  
  func get() -> [Response] {
    return responses
  }
  
  func getType() -> symptomType {
    return type
  }
  
  func submit(_ desc: String,_ image: UIImage?, _ frequency : TimeInterval?, _ submissions : Int) {
    let currentTime = Date().toTime()
    let imageData = image == nil ? nil : image!.jpegData(compressionQuality: 0.7)
    
    guard let freq = frequency else {
      let data = SymptomData(
        time: currentTime,
        type: type.rawValue,
        responses: self.responses,
        desc: desc,
        image: imageData
      )
      return Store.instance.add(data)
    }
    
    
    
    let start = TimeInterval(currentTime).advanced(by: -(freq*Double(submissions-1)))
    
    for i in 0..<submissions {
      let data = SymptomData(
        time: Int32(start.advanced(by: freq*Double(i))),
        type: type.rawValue,
        responses: self.responses,
        desc: desc,
        image: imageData
      )
      Store.instance.add(data)
    }
  }
  
}
