//
//  LegendViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/09.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

class LegendViewController: UITableViewController {
    /*
     *  戻る
     */
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
