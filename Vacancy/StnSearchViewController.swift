//
//  StnSearchViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import GoogleMobileAds

class StnSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    /*
     *  OUTLET
     */
    @IBOutlet var stnSearchBar: UISearchBar!
    @IBOutlet var stnListTableView: UITableView!
    
    //TableViewの中身
    var list: [String] = []
    //セクション名
    var sectionName = HISTORY_SEARCH_TEXT
    //履歴
    var history: [String] = []
    
    //AppDelegate
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad(){
        super.viewDidLoad()
        stnSearchBar.delegate = self
        stnListTableView.delegate = self
        
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
        loadHistory()
        showList()
        stnListTableView.reloadData()
        
        //キーボード表示を監視
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    /*
     *  キーボード表示
     */
    func handleKeyboardWillShowNotification(_ notification: Notification) {
        stnSearchBar.showsCancelButton = true
    }
    
    /*
     *  searchBarのキャンセルボタンクリック
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stnSearchBar.showsCancelButton = false
        stnSearchBar.resignFirstResponder()
    }
    
    /*
     *  searchBar変更
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        list.removeAll()
        if searchText == "" {
            //履歴検索
            sectionName = HISTORY_SEARCH_TEXT
            list = history
        }else {
            //駅名検索
            sectionName = STN_SEARCH_TEXT
            for (stn, _) in TrainData.pushcode{
                if stn.contains(searchText){
                    list.append(stn)
                }
            }
        }
        stnListTableView.reloadData()
    }
    /*
     *  TableViewメソッド
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        if sectionName == HISTORY_SEARCH_TEXT {
            //履歴検索
            list = history
        }
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
        }else if app.stnType == 2{
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
     *  履歴の読み込み
     */
    func loadHistory() {
        showList()
        let defaults = UserDefaults.standard
        let stnhist = defaults.object(forKey: "stn_history")
        if stnhist as? [String] != nil {
            history = (stnhist as? [String])!
            list = history
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
        defaults.set(history, forKey: "stn_history")
        showList()
    }
    /*
     *  履歴を削除
     */
    @IBAction func deleteHistory(_ sender: AnyObject) {
        let alert = UIAlertController(title: "確認", message: "駅名の履歴を削除します。よろしいですか？", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            //OKボタンクリック
            self.history.removeAll()
            if self.sectionName == HISTORY_SEARCH_TEXT {
                self.list.removeAll()
            }
            self.addHistory("")
            self.stnListTableView.reloadData()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {
            (action: UIAlertAction) -> Void in
            //キャンセルボタンクリック
        })
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
