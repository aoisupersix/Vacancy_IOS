//
//  BookMarkRootViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import DZNEmptyDataSet

class BookMarkRootViewController: UIViewController, GADBannerViewDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    /*
     *  AppDelegate
     */
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var Items: Results<SearchSettings>? {
        do {
            let realm = try Realm()
            return realm.objects(SearchSettings.self)
        }catch {
            print("Realmエラー")
        }
        return nil
    }
    
    /*
     *  TableView
     */
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //イベント登録
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(BookMarkRootViewController.cellLongPressed(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        //デリゲート
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        //TableViewのセルを見えなくする
        let footerView = UIView()
        footerView.backgroundColor = UIColor.black
        tableView.tableFooterView = footerView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController!.isToolbarHidden = true
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     *  EmptyDataSet
     */
//    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage {
//        return UIImage(named: "selectedMaru.png")!
//    }
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString {
        let title = "ブックマークが空です。"
//        let attributed = [
//            NSForegroundColorAttributeName: UIColor.brownColor(),
//            NSFontAttributeName: UIFont(name: "HiraKakuProN-W3", size: 10 ?? UIFont.systemFontSize()),
//            NSParagraphStyleAttributeName: (NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle).alignment = NSTextAlignment.Center,
//            ]
        
        return NSAttributedString(string: title)
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString {
        let description = "現在の照会条件をブックマークに追加するには、右上の追加ボタンを押してください。"
        
        return NSAttributedString(string: description)
    }
    
    /*
     *  TableViewメソッド
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Realm:\(Items!.count)")
        return Items!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookMarkCell") as! BookMarkCell
        
        //Realmデータを整形
        let bookmark = Items?[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm発"
        let date = formatter.string(from: bookmark!.date)
        
        cell.bookMarkTitleLabel.text = bookmark!.name
        cell.bookMarkMsgLabel.text = "\(date) \(bookmark!.dep_stn) → \(bookmark!.arr_stn)"
        if loadDefault() == (indexPath as NSIndexPath).row {
            cell.bookMarkCheckImage.image = UIImage(named: "selectedMaru.png")
        }else {
            cell.bookMarkCheckImage.image = UIImage(named: "maru.png")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark = Items?[indexPath.row]
        
        //データをセット
        app.date = (bookmark?.date)!
        app.type = (bookmark?.type)!
        app.dep_stn = (bookmark?.dep_stn)!
        app.dep_push = (bookmark?.dep_push)!
        app.arr_stn = (bookmark?.arr_stn)!
        app.arr_push = (bookmark?.arr_push)!
        
        _ = navigationController?.popViewController(animated: true)
    }
    //長押し時のイベント
    func cellLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if recognizer.state == UIGestureRecognizerState.began && indexPath != nil {
            print("longPress:\((indexPath! as NSIndexPath).row)")
            let alert = UIAlertController(title: "ブックマークを編集", message: "", preferredStyle: .actionSheet)
            let changeName = UIAlertAction(title: "ブックマーク名を変更", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                //名前変更
                let alert = UIAlertController(title: "ブックマーク名を変更", message: "変更するブックマーク名を入力してください。", preferredStyle: .alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (action: UIAlertAction!) -> Void in
                    //OKボタンクリック
                    let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
                    
                    if textFields![0].text == ""{
                        //条件名未入力
                        let alert = UIAlertController(title: "エラー", message: "ブックマーク名が未入力です。", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                    }else {
                        //名前を変更
                        self.changeName((indexPath! as NSIndexPath).row, name: textFields![0].text!)
                        self.tableView.reloadData()
                    }
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                
                alert.addTextField(configurationHandler: {(text: UITextField!) -> Void in
                    text.text = self.loadName((indexPath! as NSIndexPath).row)
                })
                
                self.present(alert, animated: true, completion: nil)
                
            })
            let setDefault = UIAlertAction(title: "起動時の照会条件に設定", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                //標準設定に設定
                self.setDefault((indexPath! as NSIndexPath).row)
                self.tableView.reloadData()
            })
            let deleteBook = UIAlertAction(title: "削除", style: .destructive, handler: {
                (action: UIAlertAction!) -> Void in
                //削除
                self.deleteItem((indexPath! as NSIndexPath).row)
                self.tableView.reloadData()
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            
            alert.addAction(changeName)
            alert.addAction(setDefault)
            alert.addAction(deleteBook)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
     *  現在の条件をブックマークに追加
     */
    
    @IBAction func addBookMark(_ sender: AnyObject) {
        let userdefaults = UserDefaults.standard
        if userdefaults.object(forKey: S_BOOKMARK_AUTOCOMPLETE) as! String == S_FALSE {
            //確認アラートを表示
            let alert = UIAlertController(title: "照会条件を追加", message: "現在の照会条件：\n\n\(app.month)月\(app.day)日 \(app.hour):\(app.minute)発\n\(app.trainType[Int(app.type)! - 1])\n\(app.dep_stn) → \(app.arr_stn)\n\nをブックマークに追加します。分かりやすいブックマーク名を入力してください。", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                //OKボタンクリック
                let textFields:Array<UITextField>? = alert.textFields as Array<UITextField>?
                
                if textFields![0].text == ""{
                    //条件名未入力
                    let alert = UIAlertController(title: "エラー", message: "ブックマーク名が未入力です。", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    //ブックマークに追加
                    self.addRealm(textFields![0].text!)
                    self.tableView.reloadData()
                }
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            
            alert.addAction(defaultAction)
            alert.addAction(cancelAction)
            
            alert.addTextField(configurationHandler: {(text: UITextField!) -> Void in
                text.placeholder = "ブックマーク名を入力"
            })
            
            self.present(alert, animated: true, completion: nil)
        }else {
            //簡略入力
            addRealm("ブックマーク\(Items!.count + 1)")
            tableView.reloadData()
        }
    }
    
    /*
     *  照会条件を削除
     */
    @IBAction func deleteAll(_ sender: AnyObject) {
        let alert = UIAlertController(title: "確認", message: "ブックマークを全て削除します。\nよろしいですか?", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            //OKボタンクリック
            self.deleteAllBookMarks()
            self.deleteDefault()
            self.tableView.reloadData()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     *  Realmメソッド
     */
    
    //追加
    func addRealm(_ bookName: String) {
        let model = SearchSettings(value: ["name": bookName, "date": app.date, "type": app.type, "dep_stn": app.dep_stn, "dep_push": app.dep_push, "arr_stn": app.arr_stn, "arr_push": app.arr_push])
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(model)
        }
    }
    
    //名前変更
    func changeName(_ index: Int, name: String) {
        let realm = try! Realm()
        let items = realm.objects(SearchSettings.self)
        try! realm.write {
            items[index].name = name
        }
    }
    
    //一つ削除
    func deleteItem(_ index: Int) {
        let realm = try! Realm()
        let items = realm.objects(SearchSettings.self)
        try! realm.write {
            realm.delete(items[index])
        }
        
        //もしデフォルトだったらそれも削除
        if index == loadDefault() {
            deleteDefault()
        }
    }
    
    //全削除
    func deleteAllBookMarks() {
        let realm = try! Realm()
        let items = realm.objects(SearchSettings.self)
        for item in items {
            try! realm.write {
                realm.delete(item)
            }
        }
    }
    
    //標準設定のインデックス読み込み
    func loadDefault() -> Int{
        var index = -1
        
        let realm = try! Realm()
        let setting = realm.objects(Setting.self)
        if setting.count == 1 {
            index = setting[0].defaultBookMark
        }
        
        return index
    }
    
    //名前読み込み
    func loadName(_ index: Int) -> String {
        let realm = try! Realm()
        let name = realm.objects(SearchSettings.self)[index].name
        
        return name
    }
    //標準設定に指定
    func setDefault(_ index: Int) {
        print("標準設定:\(index)")
        let realm = try! Realm()
        let setting = realm.objects(Setting.self)
        if setting.count == 1 {
            try! realm.write {
                setting[0].defaultBookMark = index
            }
        }else {
            //新たに設定
            let model = Setting(value: ["defaultBookMark": index])
            try! realm.write {
                realm.add(model)
            }
        }
    }
    
    //標準設定を削除
    func deleteDefault() {
        let realm = try! Realm()
        let setting = realm.objects(Setting.self)
        try! realm.write {
            realm.delete(setting)
        }
    }
}
