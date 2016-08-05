//
//  ViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, PopUpDatePickerViewDelegate, PopUpPickerViewDelegate,NSURLSessionDataDelegate{

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
     *  設定画面へ
     */
    @IBAction func goSetting(sender: AnyObject) {
        let settingView = self.storyboard!.instantiateViewControllerWithIdentifier("SettingView") as! UINavigationController
        settingView.modalTransitionStyle = .CoverVertical
        self.presentViewController(settingView, animated: true, completion: nil)
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
    }
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        updateLabels()
    }
    /*
     *  TableViewCell選択
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch indexPath.row{
        case 0:
            //乗車日設定
            datepicker.showPicker()
            break
        case 1:
            //列車の種類変更
            trainTypePicker.showPicker()
            break
        case 2:
            //出発駅
            let stnView = self.storyboard!.instantiateViewControllerWithIdentifier("StnView") as! UINavigationController
            stnView.modalTransitionStyle = .CoverVertical
            app.stnType = 1
            self.presentViewController(stnView, animated: true, completion: nil)
            //self.navigationController?.pushViewController(StnViewController(), animated: true)
            break
        case 3:
            //到着駅
            let stnView = self.storyboard!.instantiateViewControllerWithIdentifier("StnView") as! UINavigationController
            stnView.modalTransitionStyle = .CoverVertical
            app.stnType = 2
            self.presentViewController(stnView, animated: true, completion: nil)
            break
        case 4:
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

        updateDate()
        
        //列車の種類
        trainTypeLabel.text = app.trainType[Int(app.type)! - 1]
        //出発駅
        depStnLabel.text = "\(app.dep_stn)(\(app.dep_push))"
        //到着駅
        arrStnLabel.text = "\(app.arr_stn)(\(app.arr_push))"
    }
    /*
     *  時刻を更新
     */
    func updateDate() {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH時mm分"
        let date = formatter.stringFromDate(app.date)
        
        //変数代入
        app.month = date.substringWithRange(date.startIndex.advancedBy(5)..<date.endIndex.advancedBy(-10))
        app.day = date.substringWithRange(date.startIndex.advancedBy(8)..<date.endIndex.advancedBy(-7))
        app.hour = date.substringWithRange(date.startIndex.advancedBy(11)..<date.endIndex.advancedBy(-4))
        app.minute = date.substringWithRange(date.startIndex.advancedBy(14)..<date.endIndex.advancedBy(-1))
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
        print("\n(trainType[numbers[0]])選択")
        let type = String(numbers[0] + 1)
        app.type = type
        updateLabels()
    }
    /*
     *  Post送信
     */
    @IBAction func postVacancy(sender: AnyObject) {
        post()
    }
    func post() {
        //カッコは削除
        let dep_stn = deleteKakko(app.dep_stn)
        let arr_stn = deleteKakko(app.arr_stn)
        let urlString = "http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do?script=0&month=\(app.month)&day=\(app.day)&hour=\(app.hour)&minute=\(app.minute)&train=\(app.type)&dep_stn=\(dep_stn)&arr_stn=\(arr_stn)&dep_stnpb=\(app.dep_push)&arr_stnpb=\(app.arr_push)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLFragmentAllowedCharacterSet() )!)!)
        //設定
        print(urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLFragmentAllowedCharacterSet() )!)
        request.HTTPMethod = "POST"
        request.addValue("http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do", forHTTPHeaderField: "Referer")
        app.url = request.URL
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
            if (error == nil) {
                //照会結果表示
                print(NSString(data: data!, encoding: NSShiftJISStringEncoding))
                TrainData.setResult(NSString(data: data!, encoding: NSShiftJISStringEncoding)! as String)
                
                switch(TrainData.documentType){
                case 0:
                    //照会結果あり
                    if self.title == "空席照会" {
                        let resultView = self.storyboard!.instantiateViewControllerWithIdentifier("ResultView") as! UINavigationController
                        resultView.modalTransitionStyle = .FlipHorizontal
                        self.presentViewController(resultView, animated: true, completion: nil)
                    }else if self.title == "照会結果" {
                        self.loadView()
                        self.viewDidLoad()
                    }
                    break
                case 1:
                    //時間外
                    self.showAlert("照会結果", mes: "受付時間外です。\n06:30~22:30の間照会可能です。")
                    break
                case 2:
                    //該当列車なし
                    self.showAlert("照会結果", mes: "該当区間を運行する照会可能な列車がありません。")
                    break
                case 3:
                    //時間エラー
                    self.showAlert("照会結果", mes: "ご希望の乗車日の照会はできません。")
                    break
                case 4:
                    //時間エラー2(?)
                    self.showAlert("照会結果", mes: "ご希望の情報はお取り扱いできません。")
                    break
                default:
                    break
                }
            } else {
                print(error)
                self.showAlert("接続エラー", mes: "ネットワークに接続できないか、サーバーがダウンしている可能性があります。")
                print("CONNECT ERROR")
            }
        })
        task.resume()

    }
    /*
     *  駅名のカッコを削除
     */
    func deleteKakko(stn: String) -> String {
        var change = stn
        if (stn.rangeOfString("(") != nil) {
            change = stn.substringToIndex(stn.endIndex.advancedBy(-3))
        }
        return change
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func showAlert(title: String, mes: String){
        let alert = UIAlertController(title: title, message: mes, preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "了解", style: .Default, handler: nil)
        alert.addAction(defaultAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

