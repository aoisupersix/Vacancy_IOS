//
//  ViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UITableViewController, PopUpDatePickerViewDelegate, PopUpPickerViewDelegate, TrainDataDelegate {

    /*
     *  PopUpPickerView
     */
    var datepicker: PopUpDatePickerView!
    var trainTypePicker: PopUpPickerView!

    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /*
     *  UI OUTLET
     */
    @IBOutlet var vacancyTableView: UITableView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var trainTypeLabel: UILabel!
    @IBOutlet var depStnLabel: UILabel!
    @IBOutlet var startVacancyButton: UIButton!
    @IBOutlet var arrStnLabel: UILabel!
    @IBOutlet var adView: UIView!
    
    /*
     *  TrainDataDelegate
     */
    var trainData: TrainData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         *  PopUpDatePicker(乗車日入力)とPopUpPicker(列車の種類選択)の設定
         */
        datepicker = PopUpDatePickerView()
        trainTypePicker = PopUpPickerView()
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(datepicker)
            window.addSubview(trainTypePicker)
        } else {
            self.view.addSubview(datepicker)
            self.view.addSubview(trainTypePicker)
        }
        datepicker!.datepickerDelegate = self
        trainTypePicker.delegate = self
        trainTypePicker.selectedRows = [(Int(app.type)! - 1)]
        trainTypePicker.setSelectedRow()

        trainData = TrainData(dele: self)
                
        //時刻を1分後に変更
        //trainData!.updateDate(NSDate(timeInterval: 60, sinceDate: app.date))

    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        datepicker.pickerView.setDate(app.date as Date, animated: false)
        trainTypePicker.pickerView.selectRow(Int(app.type)! - 1, inComponent: 0, animated: true)
        trainTypePicker.reloadInputViews()
        
        self.navigationController?.isToolbarHidden = true
        
        updateLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewDisappear:\(app.day)")
        self.datepicker.endPicker()
        self.trainTypePicker.endPicker()
    }
    /*
     *  TableViewCell選択
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch (indexPath as NSIndexPath).row{
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
            let userdefaults = UserDefaults.standard
            if app.type == "5" || userdefaults.object(forKey: S_SUPEREXPRESS_USE_STNSELECT) as! String == S_FALSE{
                viewIdentifier = "StnSearchView"
            }
            let stnView = self.storyboard!.instantiateViewController(withIdentifier: viewIdentifier)
            self.navigationController?.pushViewController(stnView, animated: true)
            break
        case 3:
            //到着駅
            app.stnType = 2
            
            var viewIdentifier = "StnSelectView"
            let userdefaults = UserDefaults.standard
            if app.type == "5" || userdefaults.object(forKey: S_SUPEREXPRESS_USE_STNSELECT) as! String == S_FALSE{
                viewIdentifier = "StnSearchView"
            }
            let stnView = self.storyboard!.instantiateViewController(withIdentifier: viewIdentifier)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH時mm分"
        let date = formatter.string(from: app.date as Date)
        dateLabel.text = date

        trainData!.updateDate(app.date)
        
        //列車の種類
        trainTypeLabel.text = app.trainType[trainTypePicker.getSelectedRows()[0]]
        //出発駅
        depStnLabel.text = "\(app.dep_stn)(\(app.dep_push))"
        //到着駅
        arrStnLabel.text = "\(app.arr_stn)(\(app.arr_push))"
    }
    
    /*
     * 乗車日選択メソッド
     */
    func endPicker(){
        app.date = datepicker.pickerView.date
        updateLabels()
        datepicker.hidePicker()
    }
    func gobackView(){
        updateLabels()
    }
    
    /*
     *  列車の種類選択メソッド
     */
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return app.trainType.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return app.trainType[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelect numbers: [Int]) {
        let type = String(numbers[0] + 1)
        print(pickerView)
        app.type = type
        updateLabels()
    }
    /*
     *  Post送信
     */
    @IBAction func postVacancy(_ sender: AnyObject) {
        trainData!.post()
    }

    /*
     *  通信成功し、結果あり(delegate)
     */
    func completeConnection() {
        DispatchQueue.main.async{
            print("app.day=\(self.app.day)")
            let resultView = self.storyboard!.instantiateViewController(withIdentifier: "ResultView") as! UITableViewController
            self.navigationController?.pushViewController(resultView, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func showAlert(_ title: String, mes: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: title, message: mes, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "了解", style: .default, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

