//
//  SettingView.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/24.
//  Copyright © 2016年 Aoi Tanaka. All rights reserved.
//

import UIKit
import Eureka
import GoogleMobileAds

class SettingViewController: FormViewController, GADBannerViewDelegate {
    
    let userdefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //設定の標準(何らかの拍子にnilになってた時のため）
        let userdefaults = UserDefaults.standard
        let UseStnSelect = userdefaults.object(forKey: S_SUPEREXPRESS_USE_STNSELECT)
        let UseAnimation = userdefaults.object(forKey: S_USE_ANIMATION)
        let UseAutoComplete = userdefaults.object(forKey: S_BOOKMARK_AUTOCOMPLETE)
        if UseStnSelect == nil || UseAnimation == nil || UseAutoComplete == nil{
            //初回起動
            userdefaults.set(S_TRUE, forKey: S_SUPEREXPRESS_USE_STNSELECT) //新幹線の駅名検索の利用
            userdefaults.set(S_FALSE, forKey: S_BOOKMARK_AUTOCOMPLETE) //ブックマーク追加の簡略化
            userdefaults.set(S_TRUE, forKey: S_USE_ANIMATION) //アニメーションを使用する
        }
        
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
        
        //フォーム
        form +++ Section("照会設定")
            <<< SwitchRow(S_SUPEREXPRESS_USE_STNSELECT) {
                $0.title = "新幹線の駅名は駅名リストから選ぶ"
                $0.value = userdefaults.object(forKey: S_SUPEREXPRESS_USE_STNSELECT) as! String == S_TRUE ? true : false
                }.onChange({ (Switchrow) in
                    if Switchrow.value == true{
                        self.userdefaults.set(S_TRUE, forKey: S_SUPEREXPRESS_USE_STNSELECT)
                    }else {
                        self.userdefaults.set(S_FALSE, forKey: S_SUPEREXPRESS_USE_STNSELECT)
                    }
                })
            <<< SwitchRow(S_BOOKMARK_AUTOCOMPLETE) {
                $0.title = "ブックマーク追加の簡略化"
                $0.value = userdefaults.object(forKey: S_BOOKMARK_AUTOCOMPLETE) as! String == S_TRUE ? true : false
                }.onChange({ (Switchrow) in
                    if Switchrow.value == true{
                        self.userdefaults.set(S_TRUE, forKey: S_BOOKMARK_AUTOCOMPLETE)
                    }else {
                        self.userdefaults.set(S_FALSE, forKey: S_BOOKMARK_AUTOCOMPLETE)
                    }
                })
            <<< ButtonRow(S_STARTUP_SET_DEFAULT) {
                $0.title = "起動時の照会条件をデフォルトに戻す"
                }.onCellSelection({_,_ in
                    let alert = UIAlertController(title: "確認", message: "起動時の照会条件をデフォルトに戻します。よろしいですか？", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {
                        (action: UIAlertAction!) -> Void in
                        //OKボタンクリック
                        BookMarkRootViewController().setDefault(-1)
                    })
                    let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                        (action: UIAlertAction) -> Void in
                        //キャンセルボタンクリック
                    })
                    alert.addAction(defaultAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                })
        form +++ Section("パフォーマンス設定")
            <<< SwitchRow(S_USE_ANIMATION) {
                $0.title = "アニメーションを使用する"
                $0.value = userdefaults.object(forKey: S_USE_ANIMATION) as! String == S_TRUE ? true : false
        }.onChange({ (Switchrow) in
            if Switchrow.value == true{
                self.userdefaults.set(S_TRUE, forKey: S_USE_ANIMATION)
            }else {
                self.userdefaults.set(S_FALSE, forKey: S_USE_ANIMATION)
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
