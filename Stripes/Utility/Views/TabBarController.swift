//
//  TabBarController.swift
//  Stripes
//
//  Created by Dylan Baker on 3/17/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabBar.barTintColor = Colors.Header.get()
    self.tabBar.unselectedItemTintColor = Colors.HeaderText.get()
    
    let graph : UIViewController = GraphView()
    let item1 : UITabBarItem = UITabBarItem(title: "Visualize", image: UIImage(named: "graphIcon")!, tag: 0)
    
    graph.tabBarItem = item1
    graph.title = "Visualize"
    
    let initial : UIViewController = StripesView()
    let item2 : UITabBarItem = UITabBarItem(title: "Record", image: UIImage(named: "formIcon"), tag: 1)
    initial.tabBarItem = item2
    initial.title = "Record"
    
    let form : UIViewController = FormView()
    let item3 : UITabBarItem = UITabBarItem(title: "Export", image: UIImage(named: "exportIcon"), tag: 2)
    
    form.tabBarItem = item3
    form.title = "Export"
    
    let controllers : [UIViewController] = [graph, initial, form]
    self.viewControllers = controllers.map {view in
      UINavigationController(rootViewController: view)
    }
    self.selectedIndex = 1
  }
  
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    self.selectedViewController?.dismissChildViews()
  }
  
}
