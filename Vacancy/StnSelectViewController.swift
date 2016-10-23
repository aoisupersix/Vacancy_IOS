//
//  StnSelectController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/09.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import GoogleMobileAds

class StnSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    
    /*
     *  TableViewの中身
     */
    var list: [String] = []
    
    //履歴
    var history: [String] = []
    
    /*
     *  appdelegate
     */
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    /*
     *  新幹線の種類
     */
    var type: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //広告
        var bannerView: GADBannerView = GADBannerView()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.frame.origin = CGPoint(x: 0, y: self.view.frame.height - bannerView.frame.height)
        bannerView.frame.size = CGSize(width: self.view.frame.width, height: bannerView.frame.height)
        // AdMobで発行された広告ユニットIDを設定
        bannerView.adUnitID = UNIT_ID
        bannerView.delegate = self
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        //gadRequest.testDevices = [DEVICE_ID]
        bannerView.load(gadRequest)
        self.view.addSubview(bannerView)
    }
    override func viewWillAppear(_ animated: Bool) {
        //新幹線の種類を設定
        type = SUPEREXPRESS_NAME[Int(app.type)! - 1]
        
        loadHistory()
        updateList()
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
     *  セグメントが変更された
     */
    @IBAction func segmentChanged(_ sender: AnyObject) {
        updateList()
        tableView.reloadData()
    }
    /*
     *  TableView
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")

        cell.textLabel?.text = list[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor.blue
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    //セル選択
    func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        if app.stnType == 1{
            //出発駅の場合
            app.dep_stn = list[(indexPath as NSIndexPath).row]
            app.dep_push = TrainData.pushcode[app.dep_stn]!
        }else if app.stnType == 2 {
            //到着駅の場合
            app.arr_stn = list[(indexPath as NSIndexPath).row]
            app.arr_push = TrainData.pushcode[app.arr_stn]!
        }
        //履歴に追加
        addHistory(list[(indexPath as NSIndexPath).row])
        
        
        //メイン画面に戻る
        _ = navigationController?.popViewController(animated: true)
    }
    //セルが表示された時
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let ud = UserDefaults.standard
        if ud.object(forKey: S_USE_ANIMATION) as! String == S_TRUE {
            //フェードイン
            cell.alpha = 0.2
            UIView.animate(withDuration: 0.8, animations: { () -> Void in
                cell.alpha = 1.0
            }) 
        }
    }
    
    /*
     *  Listを更新
     */
    func updateList() {
        if segment.selectedSegmentIndex == HISTORY_SELECT {
            //履歴検索
            list = history
            
        }else {
            //リスト検索
            list = TrainData.stnList[Int(app.type)! - 1]
        }
    }

    
    /*
     *  履歴の読み込み
     */
    func loadHistory() {
        showList()
        let defaults = UserDefaults.standard
        let stnhist = defaults.object(forKey: "stn_\(type)_history")
        if stnhist as? [String] != nil {
            history = (stnhist as? [String])!
        }
    }
    /*
     *  履歴の追加
     */
    func addHistory(_ str: String) {
        //重複していたら削除
        if let pos = history.index(of: str){
            history.remove(at: pos)
        }
        //追加
        if str != "" {
            history.insert(str, at: 0)
        }
        let defaults = UserDefaults.standard
        defaults.set(history, forKey: "stn_\(type)_history")
        showList()
    }
    /*
     *  履歴の削除
     */
    @IBAction func deleteHistory(_ sender: AnyObject) {
        let alert = UIAlertController(title: "確認", message: "駅名の履歴を削除します。よろしいですか？", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            //OKボタンクリック
            self.history.removeAll()
            if self.segment.selectedSegmentIndex == NO_SELECT || self.segment.selectedSegmentIndex == HISTORY_SELECT {
                self.list.removeAll()
            }
            self.addHistory("")
            self.tableView.reloadData()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {
            (action: UIAlertAction) -> Void in
            //キャンセルボタンクリック
        })
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //デバッグ用　中身表示
    func showList() {
        print("*****HISTORY*****")
        for name in history {
            print(name)
        }
        print("*****************")
    }
}
