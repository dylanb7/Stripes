//
//  QuestionPath.swift
//  Stripes
//
//  Created by Dylan Baker on 3/9/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import Foundation

struct Question : Codable {
  var id : String
  var question : String
  var type : String
  var hasSeverity : Bool
  var hasLocation : Bool
}

class QuestionPath {
  
  private var path : [symptomType : [Question]] = [:]
  
  static let missedQuestions : [symptomType : Question] = [
    symptomType.PAIN : Question(id: "15", question: "Missed activities due to pain", type: symptomType.PAIN.rawValue, hasSeverity: false, hasLocation: false),
    symptomType.REFLUX : Question(id: "16", question: "Missed activities due to reflux", type: symptomType.PAIN.rawValue, hasSeverity: false, hasLocation: false),
    symptomType.BM :  Question(id: "17", question: "Missed activities due to BMs", type: symptomType.PAIN.rawValue, hasSeverity: false, hasLocation: false)
  ]
  
  init() {
    path[symptomType.BM] = [
      Question(id: "6", question: "Pain with BM", type: symptomType.BM.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "7", question: "Rush to the bathroom for BM", type: symptomType.BM.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "8", question: "Straining with BM", type: symptomType.BM.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "9", question: "Black Tarry BM", type: symptomType.BM.rawValue, hasSeverity: false, hasLocation: false)
    ]
    path[symptomType.REFLUX] = [
      Question(id: "2", question: "Nausea", type: symptomType.REFLUX.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "10", question: "Spit up", type: symptomType.REFLUX.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "11", question: "Regurgitated", type: symptomType.REFLUX.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "12", question: "Experienced Retching", type: symptomType.REFLUX.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "13", question: "Vomiting", type: symptomType.REFLUX.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "19", question: "Choked, gagged coughed or made sound (gurgling) with throat during or after swallowing or meals", type: symptomType.REFLUX.rawValue, hasSeverity: false, hasLocation: false),
      Question(id: "20", question: "Refused foods they once ate", type: symptomType.REFLUX.rawValue, hasSeverity: false, hasLocation: false)
    ]
    path[symptomType.PAIN] = [
      Question(id: "1", question: "Abdominal Pain", type: symptomType.PAIN.rawValue, hasSeverity: true, hasLocation: true),
      Question(id: "3", question: "Severe gastrointestinal pain lasting 2 hours or longer that interrupts participation in all activities", type: symptomType.PAIN.rawValue, hasSeverity: false, hasLocation: false),
      Question(id: "14", question: "Tilted head to side and arched back", type: symptomType.PAIN.rawValue, hasSeverity: false, hasLocation: false),
    ]
    path[symptomType.OTHER] = [
      Question(id: "18", question: "Applied pressure to abdomen with hands or furniture", type: symptomType.OTHER.rawValue, hasSeverity: false, hasLocation: true),
      Question(id: "21", question: "Sleep Disturbance", type: symptomType.OTHER.rawValue, hasSeverity: true, hasLocation: false),
      Question(id: "22", question: "Aggressive Behavior", type: symptomType.OTHER.rawValue, hasSeverity: true, hasLocation: false)
    ]
  }
  
  func getQuestions(_ type : symptomType) -> [Question] {
    return path[type]!
  }
  
}


