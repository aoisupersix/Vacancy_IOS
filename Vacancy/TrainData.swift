//
//  Pushcode.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/21.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

protocol TrainDataDelegate {
    func completeConnection()   //通信成功し、結果が返ってきた際のdelegate
    func showAlert(title: String, mes: String)  //通信失敗、もしくは結果がエラーの際のdelegate
}

class TrainData {
    /*
     *  Pushcode
     */
    static var pushcode = [String : String]()
    
    /*
     *  各新幹線の駅名リスト
     */
    static var stnList: [[String]] = [[], [], [], []]
    /*
     *  結果HTML
     */
    var result: String?
    
    /*
     *  HTMLのタイプ
     *  0: 結果あり
     *  1: 受付時間外
     *  2: 列車なし
     *  3: 時間エラー
     *  4: 時間エラー2(?)
     */
    var documentType: Int = 0
    
    /*
     *  HTML解析用
     */
    static let searchTrainName = "<td align=\"left\">"
    static let searchTrainVacancy = "<td align=\"center\">"
    static let searchNameEnd = "<"
    
    /*
     *  Delegate
     */
    var delegate: TrainDataDelegate
    
    /*
     *  appdelegate
     */
    let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    /*
     *  日付のバックアップ
     */
    var dateBackup: NSDate?
    
    init(dele: TrainDataDelegate) {
        delegate = dele
    }
    
    /*
     *  データ読み込み
     */
    static func read(){
        //Pushcode読み込み
        let csvBundle = NSBundle.mainBundle().pathForResource("pushcode", ofType: "csv")
        do {
            var csvData: String = try String(contentsOfFile: csvBundle!, encoding: NSUTF8StringEncoding)
            csvData = csvData.stringByReplacingOccurrencesOfString("\r", withString: "")
            let csvArray = csvData.componentsSeparatedByString("\n")
            for line in csvArray {
                let parts = line.componentsSeparatedByString(",")
                pushcode[parts[0]] = parts[1]
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //駅名リスト読み込み
        for index in 0..<SUPEREXPRESS_NAME.count {
            let txtBundle = NSBundle.mainBundle().pathForResource(SUPEREXPRESS_NAME[index], ofType: "txt")
            do {
                let listData: String = try String(contentsOfFile: txtBundle!, encoding: NSUTF8StringEncoding)
                let list = listData.componentsSeparatedByString("\n")
                for line in list {
                    stnList[index].append(line)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        //中身を表示
        print("*****PUSHCODE*****")
        for (stn, push) in pushcode{
            print("\(stn):\(push)")
        }
        print("******************")
        for i in 0..<stnList.count {
            print("*****\(SUPEREXPRESS_NAME[i])*****")
            for stn in stnList[i] {
                print(stn)
            }
            print("***************")
        }

    }
    /*
     *  Post
     */
    func post(){
        //駅名のカッコを削除
        let dep_stn = deleteKakko(app.dep_stn)
        let arr_stn = deleteKakko(app.arr_stn)
        
        //URL作成
        let urlString = "http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do?script=0&month=\(app.month)&day=\(app.day)&hour=\(app.hour)&minute=\(app.minute)&train=\(app.type)&dep_stn=\(dep_stn)&arr_stn=\(arr_stn)&dep_stnpb=\(app.dep_push)&arr_stnpb=\(app.arr_push)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLFragmentAllowedCharacterSet() )!)!)
        
        //設定
        print(urlString.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLFragmentAllowedCharacterSet() )!)
        request.HTTPMethod = "POST"
        request.addValue("http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do", forHTTPHeaderField: "Referer")
        app.url = request.URL
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
            if (error == nil) {
                /*
                 *  通信成功
                 */
                //print(NSString(data: data!, encoding: NSShiftJISStringEncoding))
                self.setResult(NSString(data: data!, encoding: NSShiftJISStringEncoding)! as String)
                
                switch(self.documentType){
                case 0:
                    //照会結果あり
                    self.delegate.completeConnection()
                    break
                case 1:
                    //時間外
                    self.delegate.showAlert("照会結果", mes: "受付時間外です。\n06:30~22:30の間照会可能です。")
                    break
                case 2:
                    //該当列車なし
                    self.delegate.showAlert("照会結果", mes: "該当区間を運行する照会可能な列車がありません。")
                    break
                case 3:
                    //時間エラー
                    self.delegate.showAlert("照会結果", mes: "ご希望の乗車日の照会はできません。")
                    break
                case 4:
                    //時間エラー2(?)
                    self.delegate.showAlert("照会結果", mes: "ご希望の情報はお取り扱いできません。")
                    break
                default:
                    break
                }
            } else {
                print(error)
                self.delegate.showAlert("接続エラー", mes: "ネットワークに接続できないか、サーバーがダウンしている可能性があります。")
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
    
    /*
     *  HTMLセット
     */
    func setResult(res: String) {
        
        //結果確認
        if res.containsString("ただいま、受け付け時間外のため、ご希望の情報の照会はできません。"){
            documentType = 1
        }else if res.containsString("該当区間を運転している空席照会可能な列車はありません。") {
            documentType = 2
        }else if res.containsString("ご希望の乗車日の空席状況は照会できません。") {
            documentType = 3
        }else if res.containsString("ご希望の情報はお取り扱いできません。") {
            documentType = 4
        }else {
            documentType = 0
            result = res
            checkHtml()
        }
    }
    /*
     *  HTML解析
     */
    func checkHtml(){
        //初期化
        app.name.removeAll()
        app.depTime.removeAll()
        app.arrTime.removeAll()
        app.resNoSmoke.removeAll()
        app.resSmoke.removeAll()
        app.greNoSmoke.removeAll()
        app.greSmoke.removeAll()
        app.grnNoSmoke.removeAll()
        
        var pos = result!.rangeOfString(TrainData.searchTrainName) //最初
        var parts = result!

        if app.type == "3" || app.type == "4" {
            //東北新幹線は喫煙席が存在しない
            while(parts.substringWithRange(pos!.endIndex..<pos!.endIndex.advancedBy(1)) != "グ" && pos != nil){
                
                parts = parts.substringFromIndex(pos!.endIndex)   //HTMLを分解
                
                //列車名取得
                app.name.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //出発時刻取得
                app.depTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //到着時刻取得
                app.arrTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //禁煙指定席取得
                app.resNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //喫煙指定席(未設定)
                app.resSmoke.append(changeRes("-"))
                
                //禁煙グリーン取得
                app.greNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //喫煙グリーン(未設定)
                app.greSmoke.append(changeRes("-"))
                
                //グランクラス
                app.grnNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //pos更新
                pos = parts.rangeOfString(TrainData.searchTrainName)
            }

            
        }else{
            //東北新幹線以外の列車にはグランクラスが存在しない
            while(parts.substringWithRange(pos!.endIndex..<pos!.endIndex.advancedBy(1)) != "グ" && pos != nil){

                parts = parts.substringFromIndex(pos!.endIndex)   //HTMLを分解
                
                //列車名取得
                app.name.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //出発時刻取得
                app.depTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)

                //到着時刻取得
                app.arrTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)

                //禁煙指定席取得
                app.resNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //喫煙指定席取得
                app.resSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //禁煙グリーン取得
                app.greNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //喫煙グリーン取得
                app.greSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(TrainData.searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(TrainData.searchTrainVacancy)!.endIndex)
                
                //グランクラス(未設定)
                app.grnNoSmoke.append(changeRes("-"))
                
                //pos更新
                pos = parts.rangeOfString(TrainData.searchTrainName)
                print("pos:\(pos)")
            }
            
        }
        //デバッグ用表示
        print("******列車名******")
        for nam in app.name {
            print(nam)
        }
        print("******出発時刻******")
        for nam in app.depTime {
            print(nam)
        }
        print("******到着時刻******")
        for nam in app.arrTime {
            print(nam)
        }
        print("******禁煙指定席******")
        for nam in app.resNoSmoke {
            print(nam)
        }
        print("******喫煙指定席******")
        for nam in app.resSmoke {
            print(nam)
        }
        print("******禁煙グリーン******")
        for nam in app.greNoSmoke {
            print(nam)
        }
        print("******喫煙グリーン******")
        for nam in app.greSmoke {
            print(nam)
        }
        print("******グランクラス******")
        for nam in app.grnNoSmoke {
            print(nam)
        }
    }
    /*
     *  空席情報をリソースに変換
     */
    func changeRes(str: String) -> String {
        var res = ""
        switch(str){
            case "-":
                res = "nashiW.png"
                break
            case "＊":
                //TODO
                res = "nashiW.png"
                break
            case "○":
                res = "maruW.png"
                break
            case "△":
                res = "sankakuW.png"
                break
            case "×":
                res = "batsuW.png"
                break
            default:
                break
        }
        return res
    }
    
    /*
     *  時刻を更新
     */
    func updateDate(date: NSDate) {
        //appに代入
        dateBackup = app.date
        app.date = date
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH時mm分"
        let date = formatter.stringFromDate(app.date)
        
        //変数代入
        app.month = date.substringWithRange(date.startIndex.advancedBy(5)..<date.endIndex.advancedBy(-10))
        app.day = date.substringWithRange(date.startIndex.advancedBy(8)..<date.endIndex.advancedBy(-7))
        app.hour = date.substringWithRange(date.startIndex.advancedBy(11)..<date.endIndex.advancedBy(-4))
        app.minute = date.substringWithRange(date.startIndex.advancedBy(14)..<date.endIndex.advancedBy(-1))
    }
}