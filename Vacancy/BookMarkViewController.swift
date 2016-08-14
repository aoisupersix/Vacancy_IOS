//
//  BookMarkViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/14.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import RealmSwift

class BookMarkViewController: UITableViewController {
    /*
     *  AppDelegate
     */
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var Items: Results<SearchSettings>? {
        do {
            let realm = try Realm()
            return realm.objects(SearchSettings)
        }catch {
            print("Realmエラー")
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //イベント登録
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(BookMarkViewController.cellLongPressed(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     *  TableViewメソッド
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Realm:\(Items!.count)")
        return Items!.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookMarkCell") as! BookMarkCell
        
        //Realmデータを整形
        let bookmark = Items?[indexPath.row]
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm発"
        let date = formatter.stringFromDate(bookmark!.date)
        
        cell.bookMarkTitleLabel.text = bookmark!.name
        cell.bookMarkMsgLabel.text = "\(date) \(bookmark!.dep_stn) → \(bookmark!.arr_stn)"
        if indexPath.row == 1 {
            cell.bookMarkCheckImage.image = UIImage(named: "maru.png")
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let bookmark = Items?[indexPath.row]
        
        //データをセット
        app.date = (bookmark?.date)!
        app.type = (bookmark?.type)!
        app.dep_stn = (bookmark?.dep_stn)!
        app.dep_push = (bookmark?.dep_push)!
        app.arr_stn = (bookmark?.arr_stn)!
        app.arr_push = (bookmark?.arr_push)!
        
        navigationController?.popViewControllerAnimated(true)
    }
    //長押し時のイベント
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if recognizer.state == UIGestureRecognizerState.Began && indexPath != nil {
            print("longPress:\(indexPath!.row)")
        }
    }
    
    /*
     *  現在の条件をブックマークに追加
     */
    @IBAction func addBookMark(sender: AnyObject) {
        //確認アラートを表示
        let alert = UIAlertController(title: "照会条件を追加", message: "現在の照会条件をブックマークに追加します。分かりやすい条件名を入力してください。", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
            (action: UIAlertAction!) -> Void in
            //OKボタンクリック
            let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
            
            print(textFields![0].text)
            if textFields![0].text == ""{
                //条件名未入力
                let alert = UIAlertController(title: "エラー", message: "条件名が未入力です。", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(defaultAction)
                self.presentViewController(alert, animated: true, completion: nil)
            }else {
                //ブックマークに追加
                self.addRealm(textFields![0].text!)
                self.tableView.reloadData()
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        alert.addTextFieldWithConfigurationHandler({(text: UITextField!) -> Void in
            text.placeholder = "照会条件の名前を入力"
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    /*
     *  Realmメソッド
     */
    //追加
    func addRealm(bookName: String) {
        let model = SearchSettings(value: ["name": bookName, "date": app.date, "type": app.type, "dep_stn": app.dep_stn, "dep_push": app.dep_push, "arr_stn": app.arr_stn, "arr_push": app.arr_push])
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(model)
        }
    }
}