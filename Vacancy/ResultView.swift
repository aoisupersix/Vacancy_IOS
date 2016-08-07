//
//  ResultView.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/25.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

public class ResultView: UITableViewController {
    
    override public func viewDidLoad(){
        super.viewDidLoad()
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
     *  TableView
     */
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrainData.name.count
    }
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath: NSIndexPath) -> UITableViewCell {
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultTableViewCell", forIndexPath: cellForRowAtIndexPath) as! ResultCell
        cell.trainInfoLabel.text = "\(app.dep_stn)(\(TrainData.depTime[cellForRowAtIndexPath.row]))　→　\(app.arr_stn)(\(TrainData.arrTime[cellForRowAtIndexPath.row]))"
        cell.trainImage.image = UIImage(named: "ltdexp.png")
        cell.trainNameLabel.text = TrainData.name[cellForRowAtIndexPath.row]
        cell.resNonSmokeImage.image = UIImage(named: TrainData.resNoSmoke[cellForRowAtIndexPath.row])
        cell.resSmokeImage.image = UIImage(named: TrainData.resSmoke[cellForRowAtIndexPath.row])
        cell.greNonSmokeImage.image = UIImage(named: TrainData.greNoSmoke[cellForRowAtIndexPath.row])
        cell.greSmokeImage.image = UIImage(named: TrainData.greSmoke[cellForRowAtIndexPath.row])
        cell.granNonSmokeImage.image = UIImage(named: TrainData.grnNoSmoke[cellForRowAtIndexPath.row])
        return cell
    }
    /*
     *  再度読み込み
     */
    @IBAction func sendUrl(sender: AnyObject) {
        ViewController().post()
    }
    /* 
     *  時間変更
     */
    @IBAction func before_day(sender: AnyObject) {
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        app.date = NSDate(timeInterval: -60*60*24, sinceDate: app.date)
        ViewController().updateDate()
        ViewController().post()
        
        self.loadView()
        self.viewDidLoad()
    }
    @IBAction func before_hour(sender: AnyObject) {
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        app.date = NSDate(timeInterval: -60*60, sinceDate: app.date)
        ViewController().updateDate()
        ViewController().post()
        
        self.loadView()
        self.viewDidLoad()
    }
    @IBAction func after_hour(sender: AnyObject) {
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        app.date = NSDate(timeInterval: 60*60*24, sinceDate: app.date)
        ViewController().updateDate()
        ViewController().post()
        
        self.loadView()
        self.viewDidLoad()
    }
    @IBAction func after_day(sender: AnyObject) {
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        app.date = NSDate(timeInterval: 60*60, sinceDate: app.date)
        ViewController().updateDate()
        ViewController().post()
        
        self.loadView()
        self.viewDidLoad()
    }
    
}
