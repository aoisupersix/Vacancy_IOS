//
//  Pushcode.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/21.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit

class TrainData {
    /*
     *  Pushcode
     */
    static var pushcode = [String : String]()
    
    /*
     *  結果HTML
     */
    static var result: String?
    
    /*
     *  HTMLのタイプ
     *  0: 結果あり
     *  1: 受付時間外
     *  2: 列車なし
     *  3: 時間エラー
     */
    static var documentType: Int = 0
    
    /*
     *  照会内容
     */
    static var name: [String] = []
    static var depTime: [String] = []
    static var arrTime: [String] = []
    static var resNoSmoke: [String] = []
    static var resSmoke: [String] = []
    static var greNoSmoke: [String] = []
    static var greSmoke: [String] = []
    static var grnNoSmoke: [String] = []
    
    /*
     *  HTML解析用
     */
    static let searchTrainName = "<td align=\"left\">"
    static let searchTrainVacancy = "<td align=\"center\">"
    static let searchNameEnd = "<"
    
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
        //中身を表示
        for (stn, push) in pushcode{
            print("\(stn):\(push)")
        }
    }
    
    /*
     *  HTMLセット
     */
    static func setResult(res: String) {
        result = res
        
        //結果確認
        if res.containsString("ただいま、受け付け時間外のため、ご希望の情報の照会はできません。"){
            documentType = 1
        }else if res.containsString("該当区間を運転している空席照会可能な列車はありません。") {
            documentType = 2
        }else if res.containsString("ご希望の乗車日の空席状況は照会できません。") {
            documentType = 3
        }else {
            documentType = 0
            checkHtml()
        }
    }
    /*
     *  HTML解析
     */
    static func checkHtml(){
        //初期化
        name.removeAll()
        depTime.removeAll()
        arrTime.removeAll()
        resNoSmoke.removeAll()
        resSmoke.removeAll()
        greNoSmoke.removeAll()
        greSmoke.removeAll()
        grnNoSmoke.removeAll()
        
        let app: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var pos = result!.rangeOfString(searchTrainName) //最初
        var parts = result!
        if app.type == "3" || app.type == "4" {
            //東北新幹線は喫煙席が存在しない
            while(parts.substringWithRange(pos!.endIndex..<pos!.endIndex.advancedBy(1)) != "グ" && pos != nil){
                print("きたよー")
                
                parts = parts.substringFromIndex(pos!.endIndex)   //HTMLを分解
                
                //列車名取得
                name.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //出発時刻取得
                depTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //到着時刻取得
                arrTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //禁煙指定席取得
                resNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //喫煙指定席(未設定)
                resSmoke.append(changeRes("-"))
                
                //禁煙グリーン取得
                greNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //喫煙グリーン(未設定)
                greSmoke.append(changeRes("-"))
                
                //グランクラス
                grnNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //pos更新
                pos = parts.rangeOfString(searchTrainName)
            }

            
        }else{
            //東北新幹線以外の列車にはグランクラスが存在しない
            while(parts.substringWithRange(pos!.endIndex..<pos!.endIndex.advancedBy(1)) != "グ" && pos != nil){
                print("きたよー")

                parts = parts.substringFromIndex(pos!.endIndex)   //HTMLを分解
                
                //列車名取得
                name.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //出発時刻取得
                depTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)

                //到着時刻取得
                arrTime.append(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1)))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)

                //禁煙指定席取得
                resNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //喫煙指定席取得
                resSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //禁煙グリーン取得
                greNoSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //喫煙グリーン取得
                greSmoke.append(changeRes(parts.substringWithRange(parts.startIndex..<parts.rangeOfString(searchNameEnd)!.endIndex.advancedBy(-1))))
                parts = parts.substringFromIndex(parts.rangeOfString(searchNameEnd)!.endIndex)  //HTMLを分解
                parts = parts.substringFromIndex(parts.rangeOfString(searchTrainVacancy)!.endIndex)
                
                //グランクラス(未設定)
                grnNoSmoke.append(changeRes("-"))
                
                //pos更新
                pos = parts.rangeOfString(searchTrainName)
            }
            
        }
        //デバッグ用表示
        print("******列車名******")
        for nam in name {
            print(nam)
        }
        print("******出発時刻******")
        for nam in depTime {
            print(nam)
        }
        print("******到着時刻******")
        for nam in arrTime {
            print(nam)
        }
        print("******禁煙指定席******")
        for nam in resNoSmoke {
            print(nam)
        }
        print("******喫煙指定席******")
        for nam in resSmoke {
            print(nam)
        }
        print("******禁煙グリーン******")
        for nam in greNoSmoke {
            print(nam)
        }
        print("******喫煙グリーン******")
        for nam in greSmoke {
            print(nam)
        }
        print("******グランクラス******")
        for nam in grnNoSmoke {
            print(nam)
        }
    }
    /*
     *  空席情報をリソースに変換
     */
    static func changeRes(str: String) -> String {
        var res = ""
        switch(str){
            case "-":
                res = "nashi.png"
                break
            case "*":
                //TODO
                res = "nashi.png"
                break
            case "○":
                res = "maru.png"
                break
            case "△":
                res = "sankaku.png"
                break
            case "×":
                res = "batsu.png"
                break
            default:
                break
        }
        return res
    }
}