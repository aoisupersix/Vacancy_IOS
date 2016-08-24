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
