//
//  Pushcode.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/21.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import SwiftSpinner

protocol TrainDataDelegate {
    func completeConnection()   //通信成功し、結果が返ってきた際のdelegate
    func showAlert(_ title: String, mes: String)  //通信失敗、もしくは結果がエラーの際のdelegate
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
     *  列車名
     */
    static var ltdExpList: [String] = []
    static var rapidList: [String] = []
    
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
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /*
     *  日付のバックアップ
     */
    var dateBackup: Date?
    
    init(dele: TrainDataDelegate) {
        delegate = dele
    }
    
    /*
     *  データ読み込み
     */
    static func read(){
        //Pushcode読み込み
        let csvBundle = Bundle.main.path(forResource: "pushcode", ofType: "csv")
        do {
            var csvData: String = try String(contentsOfFile: csvBundle!, encoding: String.Encoding.utf8)
            csvData = csvData.replacingOccurrences(of: "\r", with: "")
            let csvArray = csvData.components(separatedBy: "\n")
            for line in csvArray {
                let parts = line.components(separatedBy: ",")
                pushcode[parts[0]] = parts[1]
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //駅名リスト読み込み
        for index in 0..<SUPEREXPRESS_NAME.count {
            let txtBundle = Bundle.main.path(forResource: SUPEREXPRESS_NAME[index], ofType: "txt")
            do {
                let listData: String = try String(contentsOfFile: txtBundle!, encoding: String.Encoding.utf8)
                let list = listData.components(separatedBy: "\n")
                for line in list {
                    stnList[index].append(line)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        //特急名読み込み
        var txtBundle = Bundle.main.path(forResource: "LtdExpList", ofType: "txt")
        do {
            let listData: String = try String(contentsOfFile: txtBundle!, encoding: String.Encoding.utf8)
            let list = listData.components(separatedBy: "\n")
            for line in list {
                ltdExpList.append(line)
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //快速名読み込み
        txtBundle = Bundle.main.path(forResource: "RapidList", ofType: "txt")
        do {
            let listData: String = try String(contentsOfFile: txtBundle!, encoding: String.Encoding.utf8)
            let list = listData.components(separatedBy: "\n")
            for line in list {
                rapidList.append(line)
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    /*
     *  Post
     */
    func post(){
        //スピナー表示
        SwiftSpinner.show("照会中...")
        
        //駅名のカッコを削除
        let dep_stn = deleteKakko(app.dep_stn)
        let arr_stn = deleteKakko(app.arr_stn)
        
        //URL作成
        let urlString = "http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do?script=0&month=\(app.month)&day=\(app.day)&hour=\(app.hour)&minute=\(app.minute)&train=\(app.type)&dep_stn=\(dep_stn)&arr_stn=\(arr_stn)&dep_stnpb=\(app.dep_push)&arr_stnpb=\(app.arr_push)"
        var request = URLRequest(url: URL(string: urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlFragmentAllowed )!)!)
        
        //設定
        print(urlString.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlFragmentAllowed )!)
        request.httpMethod = "POST"
        request.addValue("http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do", forHTTPHeaderField: "Referer")
        app.url = request.url
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if (error == nil) {
                /*
                 *  通信成功
                 */
                //print(NSString(data: data!, encoding: NSShiftJISStringEncoding))
                self.setResult(NSString(data: data!, encoding: String.Encoding.shiftJIS.rawValue)! as String)
                
                let random : Double = Double(arc4random_uniform(10))
                let sleepTime = 0.2 + random / 10
                sleep(UInt32(sleepTime))
                SwiftSpinner.hide()
                
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
                    print(self.dateBackup!)
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
                SwiftSpinner.hide()
                self.delegate.showAlert("接続エラー", mes: "ネットワークに接続できないか、サーバーがダウンしている可能性があります。")
                print("CONNECT ERROR")
            }
        })
        task.resume()
    }
    
    /*
     *  駅名のカッコを削除
     */
    func deleteKakko(_ stn: String) -> String {
        var change = stn
        if (stn.range(of: "(") != nil) {
            change = stn.substring(to: stn.characters.index(stn.endIndex, offsetBy: -3))
        }
        return change
    }
    
    /*
     *  HTMLセット
     */
    func setResult(_ res: String) {
        
        //結果確認
        if res.contains("ただいま、受け付け時間外のため、ご希望の情報の照会はできません。"){
            documentType = 1
        }else if res.contains("該当区間を運転している空席照会可能な列車はありません。") {
            documentType = 2
        }else if res.contains("ご希望の乗車日の空席状況は照会できません。") {
            documentType = 3
        }else if res.contains("ご希望の情報はお取り扱いできません。") {
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
        app.trainIcon.removeAll()
        app.depTime.removeAll()
        app.arrTime.removeAll()
        app.resNoSmoke.removeAll()
        app.resSmoke.removeAll()
        app.greNoSmoke.removeAll()
        app.greSmoke.removeAll()
        app.grnNoSmoke.removeAll()
        
        let regex = Regex(self.result!)    //正規表現 -> regex.swift
        
        if app.type == "3" || app.type == "4" {
            //東北新幹線の場合
            //喫煙席は存在しない
            
            //列車名と列車アイコン取得
            let trainName = regex.matches(pattern: REGEX_TOHOKU, range: CAP_TOHOKU_NAME)
            for nam in trainName! {
                app.name.append(nam)
                app.trainIcon.append(changeIcon(app.name[app.name.count - 1]))
            }
            
            //出発時刻取得
            let depTime = regex.matches(pattern: REGEX_TOHOKU, range: CAP_TOHOKU_DEPTIME)
            for dep in depTime! {
                app.depTime.append(dep)
            }
            
            //到着時刻取得
            let arrTime = regex.matches(pattern: REGEX_TOHOKU, range: CAP_TOHOKU_ARRTIME)
            for arr in arrTime! {
                app.arrTime.append(arr)
            }
            
            //指定席取得
            let reserved = regex.matches(pattern: REGEX_TOHOKU, range: CAP_TOHOKU_RESERVED)
            for res in reserved! {
                app.resNoSmoke.append(changeRes(res))
                app.resSmoke.append(changeRes("-"))
            }
            
            //グリーン車取得
            let green = regex.matches(pattern: REGEX_TOHOKU, range: CAP_TOHOKU_GREEN)
            for gre in green! {
                app.greNoSmoke.append(changeRes(gre))
                app.greSmoke.append(changeRes("-"))
            }
            
            //グランクラス取得
            let granclass = regex.matches(pattern: REGEX_TOHOKU, range: CAP_TOHOKU_GRAN)
            for grn in granclass! {
                app.grnNoSmoke.append(changeRes(grn))
            }

        }else{
            //それ以外の列車の場合
            //グランクラスは存在しない
            
            //列車名と列車アイコン取得
            let trainName = regex.matches(pattern: REGEX_ELSE, range: CAP_TOHOKU_NAME)
            for nam in trainName! {
                app.name.append(nam)
                app.trainIcon.append(changeIcon(app.name[app.name.count - 1]))
            }
            
            //出発時刻取得
            let depTime = regex.matches(pattern: REGEX_ELSE, range: CAP_ELSE_DEPTIME)
            for dep in depTime! {
                app.depTime.append(dep)
            }
            
            //到着時刻取得
            let arrTime = regex.matches(pattern: REGEX_ELSE, range: CAP_ELSE_ARRTIME)
            for arr in arrTime! {
                app.arrTime.append(arr)
            }
            
            //禁煙指定席取得
            let reservedNs = regex.matches(pattern: REGEX_ELSE, range: CAP_ELSE_RESERVED_NONSMOKE)
            for resNs in reservedNs! {
                app.resNoSmoke.append(changeRes(resNs))
            }
            
            //喫煙指定席取得
            let reservedS = regex.matches(pattern: REGEX_ELSE, range: CAP_ELSE_RESERVED_SMOKE)
            for resS in reservedS! {
                app.resSmoke.append(changeRes(resS))
            }

            
            //禁煙グリーン車取得
            let greenNs = regex.matches(pattern: REGEX_ELSE, range: CAP_ELSE_GREEN_NONSMOKE)
            for greNs in greenNs! {
                app.greNoSmoke.append(changeRes(greNs))
            }
            
            //喫煙グリーン車取得
            let greenS = regex.matches(pattern: REGEX_ELSE, range: CAP_ELSE_GREEN_SMOKE)
            for greS in greenS! {
                app.greSmoke.append(changeRes(greS))
                //グランクラスも未設定にする
                app.grnNoSmoke.append(changeRes("-"))
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
    func changeRes(_ str: String) -> String {
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
     *  列車のアイコンを指定
     */
    func changeIcon(_ trainName: String) -> String {
        var res = ""
        if app.type == "5" {
            //在来線の場合
            for line in TrainData.ltdExpList {
                if trainName.contains(line) {
                    res = "ltdexp.png"
                    break
                }
            }
            for line in TrainData.rapidList {
                if trainName.contains(line) {
                    res = "rapid.png"
                    break
                }
            }
        }else {
            //新幹線の場合
            res = "superexpress.png"
        }
        return res
    }
    
    /*
     *  時刻を更新
     */
    func updateDate(_ date: Date) {
        //appに代入
        dateBackup = app.date as Date
        app.date = date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH時mm分"
        print("Update: \(formatter.string(from: app.date as Date))")
        let date = formatter.string(from: app.date as Date)
        
        //変数代入
        app.month = date.substring(with: date.characters.index(date.startIndex, offsetBy: 5)..<date.characters.index(date.endIndex, offsetBy: -10))
        app.day = date.substring(with: date.characters.index(date.startIndex, offsetBy: 8)..<date.characters.index(date.endIndex, offsetBy: -7))
        app.hour = date.substring(with: date.characters.index(date.startIndex, offsetBy: 11)..<date.characters.index(date.endIndex, offsetBy: -4))
        app.minute = date.substring(with: date.characters.index(date.startIndex, offsetBy: 14)..<date.characters.index(date.endIndex, offsetBy: -1))
    }
}
