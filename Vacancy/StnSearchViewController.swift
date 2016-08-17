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
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad(){
        super.viewDidLoad()
        stnSearchBar.delegate = self
        stnListTableView.delegate = self
        
        //広告
        var bannerView: GADBannerView = GADBannerView()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.frame.origin = CGPointMake(0, self.view.frame.height - bannerView.frame.height)
        bannerView.frame.size = CGSizeMake(self.view.frame.width, bannerView.frame.height)
        // AdMobで発行された広告ユニットIDを設定
        bannerView.adUnitID = UNIT_ID
        bannerView.delegate = self
        bannerView.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        gadRequest.testDevices = [DEVICE_ID]
        bannerView.loadRequest(gadRequest)
        self.view.addSubview(bannerView)
    }
    override func viewWillAppear(animated: Bool) {
        loadHistory()
        showList()
        stnListTableView.reloadData()
        
        //キーボード表示を監視
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(self.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    /*
     *  キーボード表示
     */
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        stnSearchBar.showsCancelButton = true
    }
    
    /*
     *  searchBarのキャンセルボタンクリック
     */
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        stnSearchBar.showsCancelButton = false
        stnSearchBar.resignFirstResponder()
    }
    
    /*
     *  searchBar変更
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        list.removeAll()
        if searchText == "" {
            //履歴検索
            sectionName = HISTORY_SEARCH_TEXT
            list = history
        }else {
            //駅名検索
            sectionName = STN_SEARCH_TEXT
            for (stn, _) in TrainData.pushcode{
                if stn.containsString(searchText){
                    list.append(stn)
                }
            }
        }
        stnListTableView.reloadData()
    }
    /*
     *  TableViewメソッド
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName
    }
    
    // セルの内容を変更
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        if sectionName == HISTORY_SEARCH_TEXT {
            //履歴検索
            list = history
        }
        cell.textLabel?.text = list[indexPath.row]
        cell.textLabel?.textColor = UIColor.blueColor()
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
        
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    //セル選択
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        if app.stnType == 1{
            //出発駅の場合
            app.dep_stn = list[indexPath.row]
            app.dep_push = TrainData.pushcode[app.dep_stn]!
        }else if app.stnType == 2{
            //到着駅の場合
            app.arr_stn = list[indexPath.row]
            app.arr_push = TrainData.pushcode[app.arr_stn]!
        }
        //履歴に追加
        addHistory(list[indexPath.row])
        
        
        //メイン画面に戻る
        navigationController?.popViewControllerAnimated(true)
    }
    
    /*
     *  履歴の読み込み
     */
    func loadHistory() {
        showList()
        let defaults = NSUserDefaults.standardUserDefaults()
        let stnhist = defaults.objectForKey("stn_history")
        if stnhist as? [String] != nil {
            history = (stnhist as? [String])!
            list = history
        }
    }
    /*
     *  履歴の追加
     */
    func addHistory(str: String) {
        //重複していたら削除
        if let pos = history.indexOf(str){
            history.removeAtIndex(pos)
        }
        //追加
        if str != "" {
            history.insert(str, atIndex: 0)
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(history, forKey: "stn_history")
        showList()
    }
    /*
     *  履歴を削除
     */
    @IBAction func deleteHistory(sender: AnyObject) {
        let alert = UIAlertController(title: "確認", message: "駅名の履歴を削除します。よろしいですか？", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            //OKボタンクリック
            self.history.removeAll()
            if self.sectionName == HISTORY_SEARCH_TEXT {
                self.list.removeAll()
            }
            self.addHistory("")
            self.stnListTableView.reloadData()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
            (action: UIAlertAction) -> Void in
            //キャンセルボタンクリック
        })
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
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
