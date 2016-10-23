//
//  ResultView.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/25.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

open class ResultView: UITableViewController, TrainDataDelegate {
    
    @IBOutlet var resultTableView: UITableView!
    @IBOutlet var infoLabel: UILabel!
    
    
    /*
     *  TrainData
     */
    var trainData: TrainData?
    
    /*
     *  appdelegate
     */
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override open func viewDidLoad(){
        super.viewDidLoad()
        
        trainData = TrainData(dele: self)
        
        /*
         *  Refresh
         */
        let refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "読み込み中")
        refresh.tintColor = UIColor.blue
        refresh.addTarget(self, action: #selector(ResultView.refreshTable), for: UIControlEvents.valueChanged)
        self.refreshControl = refresh
    }
    override open func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    func refreshTable() {
        trainData!.updateDate(app.date)
        trainData!.post()
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    override open func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear：\(app.day)")
        infoLabel.text = "\(app.month)月\(app.day)日 \(app.hour):\(app.minute)発 \(app.dep_stn) → \(app.arr_stn)"
    }
    
    /*
     *  TableView
     */
    //セルの数
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return app.name.count
    }
    //セルの中身
    override open func tableView(_ tableView: UITableView, cellForRowAt cellForRowAtIndexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: cellForRowAtIndexPath) as! ResultCell
        
        cell.trainInfoLabel.text = "\(app.dep_stn)(\(app.depTime[(cellForRowAtIndexPath as NSIndexPath).row]))　→　\(app.arr_stn)(\(app.arrTime[(cellForRowAtIndexPath as NSIndexPath).row]))"
        cell.trainImage.image = UIImage(named: app.trainIcon[(cellForRowAtIndexPath as NSIndexPath).row])
        cell.trainNameLabel.text = app.name[(cellForRowAtIndexPath as NSIndexPath).row]
        cell.resNonSmokeImage.image = UIImage(named: app.resNoSmoke[(cellForRowAtIndexPath as NSIndexPath).row])
        cell.resSmokeImage.image = UIImage(named: app.resSmoke[(cellForRowAtIndexPath as NSIndexPath).row])
        cell.greNonSmokeImage.image = UIImage(named: app.greNoSmoke[(cellForRowAtIndexPath as NSIndexPath).row])
        cell.greSmokeImage.image = UIImage(named: app.greSmoke[(cellForRowAtIndexPath as NSIndexPath).row])
        cell.granNonSmokeImage.image = UIImage(named: app.grnNoSmoke[(cellForRowAtIndexPath as NSIndexPath).row])
        
        return cell
    }
    //セルが表示された時
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let ud = UserDefaults.standard
        if ud.object(forKey: S_USE_ANIMATION) as! String == S_TRUE {
            //スライドイン
            let slideInTransform = CATransform3DTranslate(CATransform3DIdentity, 310, 15, 0)
            cell.layer.transform = slideInTransform
            cell.alpha = 0.2
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                cell.layer.transform = CATransform3DIdentity
                cell.alpha = 1.0
            }) 
        }
    }
    /*
     *  再度読み込み
     */
    @IBAction func sendUrl(_ sender: AnyObject) {
        trainData!.updateDate(app.date)
        trainData!.post()
    }
    /* 
     *  時間変更
     */
    @IBAction func before_day(_ sender: AnyObject) {
        trainData!.updateDate(Date(timeInterval: -60*60*24, since: app.date))
        trainData!.post()
    }
    @IBAction func before_hour(_ sender: AnyObject) {
        trainData!.updateDate(Date(timeInterval: -60*60, since: app.date))
        trainData!.post()
    }
    @IBAction func after_hour(_ sender: AnyObject) {
        trainData!.updateDate(Date(timeInterval: 60*60, since: app.date))
        trainData!.post()
    }
    @IBAction func after_day(_ sender: AnyObject) {
        trainData!.updateDate(Date(timeInterval: 60*60*24, since: app.date))
        trainData!.post()
    }
    /*
     *  TrainDataDelegate
     */
    func completeConnection() {
        DispatchQueue.main.async{
            print("Complete!")
            self.resultTableView.reloadData()
            self.infoLabel.text = "\(self.app.month)月\(self.app.day)日 \(self.app.hour):\(self.app.minute)発 \(self.app.dep_stn) → \(self.app.arr_stn)"
            self.refreshControl?.endRefreshing()

        }
    }
    func showAlert(_ title: String, mes: String) {
        DispatchQueue.main.async{
            self.refreshControl?.endRefreshing()
            
            let alert = UIAlertController(title: title, message: mes, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "了解", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
            print(self.trainData!.dateBackup!)
            //Dateを戻しておく
            self.app.date = self.trainData!.dateBackup!
        }
    }
}
