//
//  SearchSettings.swift
//  Vacancy
//
//  Created by 田中葵 on 2016/08/14.
//  Copyright © 2016年 田中葵. All rights reserved.
//

import Foundation
import RealmSwift

class SearchSettings: Object {
    dynamic var name = ""
    dynamic var date = NSDate()
    dynamic var type = ""
    dynamic var dep_stn = ""
    dynamic var dep_push = ""
    dynamic var arr_stn = ""
    dynamic var arr_push = ""
}
