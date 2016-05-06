//
//  RemoteEnum.swift
//  ExRemote
//
//  Created by wendy on 16/5/6.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit

//class RemoteEnum: NSObject {
//
//}

enum RemoteEnum:NSInteger {
    case up = 200//上
    case left//左
    case down//下
    case right//右
    case enter//确认
    case plus//音量增大
    case dec//音量减小
    case voice//语音
    case menu//菜单
    case back//返回
}

enum connectState:NSString{
    case scan
    case connecting;
    case connected;
    case poweredOn
    case poweredOff
    case unauthorized
}


