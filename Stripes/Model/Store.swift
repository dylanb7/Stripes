//
//  Store.swift
//  Stripes
//
//  Created by Dylan Baker on 3/4/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import Foundation

enum Keys : String {
  case username = "USERNAME"
  case data = "USERDATA"
}

protocol Stamped {
  var time : Int32 { get }
}

struct User : Codable {
  var username : String
  var info : UserInfo
  var bmi : [BMIData]
  var events : [EventData]
  var data : [SymptomData]
  var tests : [Test]
}

struct UserInfo : Codable {
  var name : String
  var gender : String
  var dob : Int32
}

enum dataType : String{
  case BMI = "BMI"
  case Event = "Event"
  case User = "Symptom"
  case Test = "Test"
}

struct BMIData : Codable, Stamped {
  var time : Int32
  var weight : Int
  var feet : Int
  var inches : Int
  
  var bmi : Double {
    get {
      let kilos : Double = Double(weight)*0.453592
      let meters : Double = Double((feet*12)+inches)*0.0254
      return round((kilos/(meters*meters))*10)/10
    }
  }
  
}

struct EventData : Codable, Stamped {
  var time : Int32
  var type : String
  var desc : [String]
}

enum eventType : String {
  case dietaryChange = "Dietary Change"
  case moved = "Moved"
  case psychiatricHospitalization = "Psychiatric Hospitalization"
  case medicalIntervention = "Medical Intervention"
  
  static func getOrdered()->[eventType]{
    return [.dietaryChange, .moved, .psychiatricHospitalization, .medicalIntervention]
  }
  
}

struct SymptomData : Codable, Stamped {
  var time : Int32
  var type : String
  var responses : [Response]
  var desc : String
  var image : Data?
}

enum symptomType : String {
  case BM = "Bowel Movement"
  case REFLUX = "Reflux"
  case PAIN = "Pain"
  case OTHER = "Other"
  
  static func getOrdered()->[symptomType]{
    return [.BM, .REFLUX, .PAIN, .OTHER]
  }
  
}

struct Test: Codable, Stamped {
  var time : Int32
  var endTime : Int32
  var type : String
  var description:  String
  var image : Data?
}

enum testType : String {
  case blueDye = "Blue Dye Test"
  
  static func getOrdered()->[testType]{
    return [.blueDye]
  }
  
}

final class Store {
  
  static let instance = Store()
  
  private let secure : UserDefaults = UserDefaults.standard
  
  private let loose : UserDefaults = UserDefaults.standard
  
  private var users : [String: User]
  
  private var current : String
  
  private init() {
    users = [:]
    current = ""
    self.load()
  }
  
  func editUser(user: User) -> Bool {
    guard (users[user.username] != nil) else { return false }
    users[user.username] = user
    self.saveUsers()
    return true
  }
  
  func addUser(user : User) -> Bool {
    if(users[user.username] == nil) {
      users[user.username] = user
      self.saveUsers()
      return true
    }
    return false
  }
  
  func removeUser(name : String) -> Bool {
    if users[name] == nil {
      return false
    }
    if current == name {
      current = users.keys.first(where: { user in return name != user }) ?? ""
    }
    users.removeValue(forKey: name)
    self.saveUsers()
    return true
  }
  
  func removeAllUsers(){
    users.removeAll()
    self.saveUsers()
  }
  
  func makeCurrent(username : String) -> Bool {
    guard users[username] != nil || current == username else { return false }
    current = username
    loose.set(current, forKey: Keys.username.rawValue)
    return true
  }
  
  func getCurrent() -> User? {
    return users[current]
  }
  
  func add(_ data : Stamped){
    guard users[current] != nil else { return }
    switch type(of: data) {
      case is SymptomData.Type:
        users[current]!.data.append(data as! SymptomData)
      case is BMIData.Type:
        users[current]!.bmi.append(data as! BMIData)
      case is EventData.Type:
        users[current]!.events.append(data as! EventData)
      case is Test.Type:
        users[current]!.tests.append(data as! Test)
      default:
        return
    }
    self.saveUsers()
  }
  
  func get(type: dataType) -> [Stamped] {
    guard let current : User = self.getCurrent() else { return [] }
    switch type {
      case .BMI:
        return current.bmi
      case .Event:
        return current.events
      case .User:
        return current.data
      case .Test:
        return current.tests
    }
  }
  
  func getSorted(types: [dataType]) -> [Stamped]{
    var list : [Stamped] = []
    for type in types {
      list.append(contentsOf: self.get(type: type))
    }
    return list.sorted(by: {
      return $0.time > $1.time
    })
  }
  
  func remove(_ time : Int32, _ type: dataType) -> Bool {
    guard var current : User = self.getCurrent() else { return false }
    switch type {
      case .BMI:
        return remove(time: time, list: &current.bmi)
      case .User:
        return remove(time: time, list: &current.data)
      case .Event:
        return remove(time: time, list: &current.events)
      case .Test:
        return remove(time: time, list: &current.tests)
    }
  }
  
  func getUsers() -> [String] {
    return Array(self.users.keys)
  }
  
  private func remove<T: Stamped>(time : Int32, list : inout [T]) -> Bool {
    for i in 0..<list.count {
      if list[i].time == time {
        list.remove(at: i)
        self.saveUsers()
        return true
      }
    }
    return false
  }
  
  private func load() {
    guard let storedData : Data = secure.data(forKey: Keys.data.rawValue) else {
      return
    }
    users = try! PropertyListDecoder().decode([String : User].self, from: storedData)
    guard let curr : String = loose.string(forKey: Keys.username.rawValue) else {
      return
    }
    current = curr
  }
  
  private func saveUsers() {
    let storable : Data = try! PropertyListEncoder().encode(users)
    secure.set(storable, forKey: Keys.data.rawValue)
  }
  
}
