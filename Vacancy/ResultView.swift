//
//  ResultView.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/25.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

public class ResultView: UITableViewController, TrainDataDelegate {
    
    @IBOutlet var resultTableView: UITableView!
    @IBOutlet var infoLabel: UILabel!
    
    /*
     *  TrainData
     */
    var trainData: TrainData?
    
    /*
     *  appdelegate
     */
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        
        trainData = TrainData(dele: self)
        
        /*
         *  Refresh
         */
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "読み込み中")
        refresh.tintColor = UIColor.blueColor()
        refresh.addTarget(self, action: #selector(ResultView.refreshTable), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
    }
    func refreshTable() {
        trainData!.post()
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override public func viewWillAppear(animated: Bool) {
        infoLabel.text = "\(app.month)月\(app.day)日 \(app.hour):\(app.minute)発 \(app.dep_stn) → \(app.arr_stn)"
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    /*
     *  TableView
     */
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return app.name.count
    }
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath: NSIndexPath) -> UITableViewCell {
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultTableViewCell", forIndexPath: cellForRowAtIndexPath) as! ResultCell
        
        cell.trainInfoLabel.text = "\(app.dep_stn)(\(app.depTime[cellForRowAtIndexPath.row]))　→　\(app.arr_stn)(\(app.arrTime[cellForRowAtIndexPath.row]))"
        cell.trainImage.image = UIImage(named: app.trainIcon[cellForRowAtIndexPath.row])
        cell.trainNameLabel.text = app.name[cellForRowAtIndexPath.row]
        cell.resNonSmokeImage.image = UIImage(named: app.resNoSmoke[cellForRowAtIndexPath.row])
        cell.resSmokeImage.image = UIImage(named: app.resSmoke[cellForRowAtIndexPath.row])
        cell.greNonSmokeImage.image = UIImage(named: app.greNoSmoke[cellForRowAtIndexPath.row])
        cell.greSmokeImage.image = UIImage(named: app.greSmoke[cellForRowAtIndexPath.row])
        cell.granNonSmokeImage.image = UIImage(named: app.grnNoSmoke[cellForRowAtIndexPath.row])
        return cell
    }
    /*
     *  再度読み込み
     */
    @IBAction func sendUrl(sender: AnyObject) {
        trainData!.post()
    }
    /* 
     *  時間変更
     */
    @IBAction func before_day(sender: AnyObject) {
        trainData!.updateDate(NSDate(timeInterval: -60*60*24, sinceDate: app.date))
        trainData!.post()
    }
    @IBAction func before_hour(sender: AnyObject) {
        trainData!.updateDate(NSDate(timeInterval: -60*60, sinceDate: app.date))
        trainData!.post()
    }
    @IBAction func after_hour(sender: AnyObject) {
        trainData!.updateDate(NSDate(timeInterval: 60*60, sinceDate: app.date))
        trainData!.post()
    }
    @IBAction func after_day(sender: AnyObject) {
        trainData!.updateDate(NSDate(timeInterval: 60*60*24, sinceDate: app.date))
        trainData!.post()
    }
    /*
     *  TrainDataDelegate
     */
    func completeConnection() {
        dispatch_async(dispatch_get_main_queue()){
            print("Complete!")
            self.resultTableView.reloadData()
            self.infoLabel.text = "\(self.app.month)月\(self.app.day)日 \(self.app.hour):\(self.app.minute)発 \(self.app.dep_stn) → \(self.app.arr_stn)"
            self.refreshControl?.endRefreshing()

        }
    }
    func showAlert(title: String, mes: String) {
        dispatch_async(dispatch_get_main_queue()){
            let alert = UIAlertController(title: title, message: mes, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "了解", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        
            //Dateを戻しておく
            self.app.date = self.trainData!.dateBackup!
        }
    }
}
