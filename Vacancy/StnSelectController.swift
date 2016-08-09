//
//  StnSelectController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/09.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

/*
 *  segment
 */


class StnSelectController: UITableViewController {
    
    @IBOutlet var segment: UISegmentedControl!
    
    /*
     *  TableViewの中身
     */
    var list: [String] = []
    
    //履歴
    var history: [String] = []
    
    /*
     *  appdelegate
     */
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    /*
     *  新幹線の種類
     */
    var type: String?
    
    /*
     *  ViewControllerに戻る
     */
    @IBAction func back(sender: AnyObject) {
        addHistory("")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
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
    @IBAction func segmentChanged(sender: AnyObject) {
        updateList()
        tableView.reloadData()
    }
    /*
     *  TableView
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    // セルの内容を変更
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")

        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    //セル選択
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        if app.stnType == 1{
            //出発駅の場合
            app.dep_stn = list[indexPath.row]
            app.dep_push = TrainData.pushcode[app.dep_stn]!
        }else if app.stnType == 2 {
            //到着駅の場合
            app.arr_stn = list[indexPath.row]
            app.arr_push = TrainData.pushcode[app.arr_stn]!
        }
        //履歴に追加
        addHistory(list[indexPath.row])
        
        
        //メイン画面に戻る
        self.dismissViewControllerAnimated(true, completion: nil)
    }
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
        let defaults = NSUserDefaults.standardUserDefaults()
        let stnhist = defaults.objectForKey("stn_\(type)_history")
        if stnhist as? [String] != nil {
            history = (stnhist as? [String])!
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
        defaults.setObject(history, forKey: "stn_\(type)_history")
        showList()
    }
    /*
     *  履歴の削除
     */
    @IBAction func deleteHistory(sender: AnyObject) {
        let alert = UIAlertController(title: "確認", message: "駅名の履歴を削除します。よろしいですか？", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            //OKボタンクリック
            self.history.removeAll()
            if self.segment.selectedSegmentIndex == HISTORY_SELECT{
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
    
    //デバッグ用　中身表示
    func showList() {
        print("*****HISTORY*****")
        for name in history {
            print(name)
        }
        print("*****************")
    }
}