//
//  ResultRegex.swift
//  Vacancy
//
//  Created by 田中葵 on 2017/01/29.
//  Copyright © 2017年 Aoi Tanaka. All rights reserved.
//

/*
 *  HTML解析用の正規表現
 */
let REGEX_TOHOKU = "(?-i)<tr>\\s*\\n\\s*<td align=\"left\">(.+)<\\/td>\\n\\s*<td align=\"center\">(\\d+:\\d+)<\\/td>\\n\\s*<td align=\"center\">(\\d+:\\d+)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>"   //東北新幹線用

let REGEX_ELSE = "(?-i)<tr>\\s*\\n\\s*<td align=\"left\">(.+)<\\/td>\\n\\s*<td align=\"center\">(\\d+:\\d+)<\\/td>\\n\\s*<td align=\"center\">(\\d+:\\d+)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>\\n\\s*<td align=\"center\">(.)<\\/td>" //その他用

/*
 *  東北新幹線用正規表現のキャプチャ
 */
let CAP_TOHOKU_NAME = 1;  //列車名
let CAP_TOHOKU_DEPTIME = 2;   //出発時刻
let CAP_TOHOKU_ARRTIME = 3;   //到着時刻
let CAP_TOHOKU_RESERVED = 4; //指定席
let CAP_TOHOKU_GREEN = 5;   //グリーン車
let CAP_TOHOKU_GRAN = 6;    //グランクラス

/*
 *  その他列車用正規表現のキャプチャ
 */
let CAP_ELSE_NAME = 1;  //列車名
let CAP_ELSE_DEPTIME = 2;   //出発時刻
let CAP_ELSE_ARRTIME = 3;   //到着時刻
let CAP_ELSE_RESERVED_NONSMOKE = 4; //禁煙指定席
let CAP_ELSE_RESERVED_SMOKE = 5; //喫煙指定席
let CAP_ELSE_GREEN_NONSMOKE = 6;   //禁煙グリーン車
let CAP_ELSE_GREEN_SMOKE = 7;   //喫煙グリーン車

