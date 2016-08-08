//
//  StnViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/21.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

/*
 *  セクション名
 */
let HISTORY_SEARCH_TEXT = "履歴から検索"
let STN_SEARCH_TEXT = "駅名から検索"

class StnViewController: UITableViewController, UISearchBarDelegate{
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
    
    /*
     *  メイン画面に戻る
     */
    @IBAction func back(sender: AnyObject) {
        addHistory("")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        stnSearchBar.delegate = self
        stnListTableView.delegate = self
        
    }
    override func viewWillAppear(animated: Bool) {
        loadHistory()
        showList()
        tableView.reloadData()
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
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName
    }
    
    // セルの内容を変更
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        if sectionName == HISTORY_SEARCH_TEXT {
            //履歴検索
            list = history
        }
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    //セル選択
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
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
        self.dismissViewControllerAnimated(true, completion: nil)
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
            self.tableView.reloadData()
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
        print("*****HISTORY*****")
    }
}
