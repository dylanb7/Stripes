//
//  DataGathering.swift
//  Stripes
//
//  Created by Dylan Baker on 7/5/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class QuestionGathering {
  
  var questionData : [String : [(time: Int32, severity: CGFloat?, location: String?)]] = [:]
  
  init() {
    Store.instance.get(type: .User).forEach({ stamp in
      let symptomRes : SymptomData = stamp as! SymptomData
      if let _ = questionData[symptomRes.type] {
        self.questionData[symptomRes.type]!.append((time: symptomRes.time, severity: nil, location: nil))
      } else {
        self.questionData[symptomRes.type] = []
        self.questionData[symptomRes.type]!.append((time: symptomRes.time, severity: nil, location: nil))
      }
      for res in symptomRes.responses {
        if let _ = questionData[res.question.text] {
          self.questionData[res.question.text]!.append((time: symptomRes.time, severity: res.severity, location: res.location))
        } else {
          self.questionData[res.question.text] = []
          self.questionData[res.question.text]!.append((time: symptomRes.time, severity: res.severity, location: res.location))
        }
      }
      
    })
  }
  
}
