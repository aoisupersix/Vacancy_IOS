//
//  ViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, PopUpDatePickerViewDelegate, PopUpPickerViewDelegate, TrainDataDelegate{

    /*
     *  PopUpPickerView
     */
    var datepicker: PopUpDatePickerView!
    var trainTypePicker: PopUpPickerView!
    
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /*
     *  UI OUTLET
     */
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var trainTypeLabel: UILabel!
    @IBOutlet var depStnLabel: UILabel!
    @IBOutlet var startVacancyButton: UIButton!
    @IBOutlet var arrStnLabel: UILabel!
    
    /*
     *  TrainDataDelegate
     */
    var trainData: TrainData?
    
    /*
     *  設定画面へ
     */
    @IBAction func goSetting(sender: AnyObject) {
        let url = NSURL(string:UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         *  PopUpDatePicker(乗車日入力)とPopUpPicker(列車の種類選択)の設定
         */
        datepicker = PopUpDatePickerView()
        trainTypePicker = PopUpPickerView()
        
        if let window = UIApplication.sharedApplication().keyWindow {
            window.addSubview(datepicker)
            window.addSubview(trainTypePicker)
        } else {
            self.view.addSubview(datepicker)
            self.view.addSubview(trainTypePicker)
        }
        datepicker!.datepickerDelegate = self
        trainTypePicker.delegate = self
        

        trainData = TrainData(dele: self)
        
        //時刻を1分後に変更
        trainData!.updateDate(NSDate(timeInterval: 60, sinceDate: app.date))
        
        //ボタンのデザインを変更
        
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        updateLabels()
        self.navigationController?.toolbarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.datepicker.endPicker()
        self.trainTypePicker.endPicker()
    }
    /*
     *  TableViewCell選択
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch indexPath.row{
        case 0:
            //乗車日設定
            self.trainTypePicker.hidePicker()
            datepicker.showPicker()
            break
        case 1:
            //列車の種類変更
            self.datepicker.hidePicker()

            trainTypePicker.showPicker()
            break
        case 2:
            //出発駅
            app.stnType = 1
            
            var viewIdentifier = "StnSelectView"
            if app.type == "5" {
                viewIdentifier = "StnView"
            }
            let stnView = self.storyboard!.instantiateViewControllerWithIdentifier(viewIdentifier) as! UITableViewController
            self.navigationController?.pushViewController(stnView, animated: true)
            break
        case 3:
            //到着駅
            app.stnType = 2
            
            var viewIdentifier = "StnSelectView"
            if app.type == "5" {
                viewIdentifier = "StnView"
            }
            let stnView = self.storyboard!.instantiateViewControllerWithIdentifier(viewIdentifier) as! UITableViewController
            self.navigationController?.pushViewController(stnView, animated: true)
            break
        default:
            break
        }
    }
    
    /*
     *  Label更新
     */
    func updateLabels(){
        //乗車日
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH時mm分"
        let date = formatter.stringFromDate(app.date)
        dateLabel.text = date

        trainData!.updateDate(app.date)
        
        //列車の種類
        trainTypeLabel.text = app.trainType[Int(app.type)! - 1]
        //出発駅
        depStnLabel.text = "\(app.dep_stn)(\(app.dep_push))"
        //到着駅
        arrStnLabel.text = "\(app.arr_stn)(\(app.arr_push))"
    }
    
    /*
     * 乗車日選択メソッド
     */
    func endPicker(){
        updateLabels()
        datepicker.hidePicker()
    }
    func gobackView(){
        updateLabels()
    }
    
    /*
     *  列車の種類選択メソッド
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return app.trainType.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return app.trainType[row]
    }
    func pickerView(pickerView: UIPickerView, didSelect numbers: [Int]) {
        let type = String(numbers[0] + 1)
        print(pickerView)
        app.type = type
        updateLabels()
    }
    /*
     *  Post送信
     */
    @IBAction func postVacancy(sender: AnyObject) {
        trainData!.post()
    }

    /*
     *  通信成功し、結果あり(delegate)
     */
    func completeConnection() {
        dispatch_async(dispatch_get_main_queue()){
            let resultView = self.storyboard!.instantiateViewControllerWithIdentifier("ResultView") as! UITableViewController
            self.navigationController?.pushViewController(resultView, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func showAlert(title: String, mes: String){
        dispatch_async(dispatch_get_main_queue()){
            let alert = UIAlertController(title: title, message: mes, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "了解", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

