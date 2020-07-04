//
//  GraphView.swift
//  Stripes
//
//  Created by Dylan Baker on 3/18/20.
//  Copyright © 2020 Dylan Baker. All rights reserved.
//

import UIKit
import Charts

class GraphView : UIViewController {
  
  private lazy var graphView : UIView = {
    let lineChart : LineChartView = LineChartView(frame: CGRect.zero)
    lineChart.translatesAutoresizingMaskIntoConstraints = false
    lineChart.backgroundColor = Colors.Text.get()
    return lineChart
  }()
  
  private var data : [Stamped] = []
  
  init() {
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    
  }
  
  @objc private func graph() {
    
  }
  
}
