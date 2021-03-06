//
//  MainViewController.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController, GADBannerViewDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
