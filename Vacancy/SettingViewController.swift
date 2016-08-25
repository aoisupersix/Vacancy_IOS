//
//  SettingView.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/24.
//  Copyright © 2016年 Aoi Tanaka. All rights reserved.
//

import UIKit
import Eureka

class SettingViewController: FormViewController {
    
    let userdefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //フォーム
        form +++ Section("照会設定")
            <<< SwitchRow(S_SUPEREXPRESS_USE_STNSELECT) {
                $0.title = "新幹線の駅名は駅名リストから選択する"
                $0.value = userdefaults.objectForKey(S_SUPEREXPRESS_USE_STNSELECT) as! String == S_TRUE ? true : false
                }.onChange({ (Switchrow) in
                    if Switchrow.value == true{
                        self.userdefaults.setObject(S_TRUE, forKey: S_SUPEREXPRESS_USE_STNSELECT)
                    }else {
                        self.userdefaults.setObject(S_FALSE, forKey: S_SUPEREXPRESS_USE_STNSELECT)
                    }
                })
            <<< ButtonRow(S_STARTUP_SET_DEFAULT) {
                $0.title = "起動時の照会条件をデフォルトに戻す"
                }.onCellSelection({_,_ in
                    let alert = UIAlertController(title: "確認", message: "起動時の照会条件をデフォルトに戻します。よろしいですか？", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: {
                        (action: UIAlertAction!) -> Void in
                        //OKボタンクリック
                        BookMarkRootViewController().setDefault(-1)
                    })
                    let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: {
                        (action: UIAlertAction) -> Void in
                        //キャンセルボタンクリック
                    })
                    alert.addAction(defaultAction)
                    alert.addAction(cancelAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
        form +++ Section("パフォーマンス設定")
            <<< SwitchRow(S_USE_ANIMATION) {
                $0.title = "アニメーションを使用する"
                $0.value = userdefaults.objectForKey(S_USE_ANIMATION) as! String == S_TRUE ? true : false
        }.onChange({ (Switchrow) in
            if Switchrow.value == true{
                self.userdefaults.setObject(S_TRUE, forKey: S_USE_ANIMATION)
            }else {
                self.userdefaults.setObject(S_FALSE, forKey: S_USE_ANIMATION)
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
