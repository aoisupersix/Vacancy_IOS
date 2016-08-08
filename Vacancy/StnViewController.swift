//
//  StnViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/21.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

class StnViewController: UITableViewController, UISearchBarDelegate{
    /*
     *  OUTLET
     */
    @IBOutlet var stnSearchBar: UISearchBar!
    @IBOutlet var stnListTableView: UITableView!
    
    //TableViewの中身
    var list: [String] = []
    
    //AppDelegate
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /*
     *  メイン画面に戻る
     */
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        stnSearchBar.delegate = self
        stnListTableView.delegate = self
    }
    /*
     *  searchBar変更
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //駅名検索
        list.removeAll()
        for (stn, _) in TrainData.pushcode{
            if stn.containsString(searchText){
                list.append(stn)
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
        }else if app.stnType == 2{
            //到着駅の場合
            app.arr_stn = list[indexPath.row]
            app.arr_push = TrainData.pushcode[app.arr_stn]!
        }
        //メイン画面に戻る
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
