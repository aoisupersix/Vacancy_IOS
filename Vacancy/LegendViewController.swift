//
//  LegendViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/09.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

class LegendViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
