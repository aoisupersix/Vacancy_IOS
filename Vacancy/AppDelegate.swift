//
//  AppDelegate.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/07/17.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var date: Date = Date() //乗車日時保存用
    var stnType = 0 //駅設定用
    var url: URL? //URL
    
    //列車の種類
    let trainType = ["東海道・山陽・九州新幹線", "東海道新幹線(こだま)", "北海道・東北・秋田・山形新幹線", "上越・長野新幹線", "在来線列車"]
    
    /*
     *  Postする情報
     */
    var month = ""
    var day = ""
    var hour = ""
    var minute = ""
    var type = "1"
    var dep_stn = "東京"
    var dep_push = "4000"
    var arr_stn = "新大阪"
    var arr_push = "6100"
    
    /*
     *  照会内容
     */
    var name: [String] = []
    var trainIcon: [String] = []
    var depTime: [String] = []
    var arrTime: [String] = []
    var resNoSmoke: [String] = []
    var resSmoke: [String] = []
    var greNoSmoke: [String] = []
    var greSmoke: [String] = []
    var grnNoSmoke: [String] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //データ読み込み
        TrainData.read()
        //標準設定
        setDefault()
        //Firebase
        FIRApp.configure()
        
        //設定の標準
        let userdefaults = UserDefaults.standard
        let UseStnSelect = userdefaults.object(forKey: S_SUPEREXPRESS_USE_STNSELECT)
        let UseAnimation = userdefaults.object(forKey: S_USE_ANIMATION)
        if UseStnSelect == nil || UseAnimation == nil{
            //初回起動
            userdefaults.set(S_TRUE, forKey: S_SUPEREXPRESS_USE_STNSELECT) //新幹線の駅名検索の利用
            userdefaults.set(S_FALSE, forKey: S_BOOKMARK_AUTOCOMPLETE) //ブックマーク追加の簡略化
            userdefaults.set(S_TRUE, forKey: S_USE_ANIMATION) //アニメーションを使用する
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "jp.gr.java-conf.aoisupersix.Vacancy" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Vacancy", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func setDefault() {
        let realm = try! Realm()
        let setting = realm.objects(Setting.self)
        if setting.count == 1 {
            let index = setting[0].defaultBookMark
            if index != -1 {
                //標準設定あり
                let items = realm.objects(SearchSettings.self)
                //セット
                date = items[index].date
                type = items[index].type
                dep_stn = items[index].dep_stn
                dep_push = items[index].dep_push
                arr_stn = items[index].arr_stn
                arr_push = items[index].arr_push
            }else {
                type = "1"
                dep_stn = "東京"
                dep_push = "4000"
                arr_stn = "新大阪"
                arr_push = "6100"
            }
        }
    }
}

