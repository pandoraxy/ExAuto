//
//  ExControlCenter.swift
//  ExAuto
//
//  Created by  mapbar_ios on 16/4/20.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit

public let notiName = "Notification"
public let userInfoKey = "order"
/// 显示层代理需要遵循的协议
public protocol ExControlProtocol:class {
    func confirm()//用户按了确认键
    func back()//用户按了back键
}
/**
 可以识别的语音指令
 
 - backOrder:  返回
 - musicOrder: 播放音乐
 - naviOrder:  导航
 - telOrder:   打电话
 */
public enum ExVROrder {
    case backOrder
    case musicOrder
    case naviOrder
    case telOrder
}
/// 控制中心类
public class ExControlCenter {
    
    //MARK:- 私有变量
        /// CC单例
    private static var singleton:ExControlCenter?
    
        /// 焦点控制
    lazy private var focusManager = ExFocusManager()

    
    //MARK:- 公有变量
    
        /// 是否显示焦点，默认显示
    public var focusHidden:Bool = false {
        didSet {
            //TODO: 隐藏或者显示焦点
        }
    }
    
        /// BLE:探测到的可用外设列表
    public var availablePeripherals:NSMutableArray = []
    
        /// 显示层代理
    public weak var displayDelegate:ExControlProtocol?
    
    
    //MARK:- 私有方法
    
    //MARK:- 公有方法
    /**
     获取控制中心的单例
     
     - returns: 控制中心的单例
     */
    public class func sharedInstance() -> ExControlCenter? {
        
        if nil == singleton {
            singleton = ExControlCenter()
            /**
             初始化单例的同时初始化下focusManager
             */
        }
        return singleton
    }
    
    //MARK:- BLE方面的方法
    /**
     连接指定BLE设备，待商榷
     */
    public func connectToPeripheral(){
        //TODO:连接指定BLE设备
    }
    
    //MARK:要交给DC处理的action
    /**
     遥控器向上
     */
    public func performUp(){
        if !focusHidden {
            focusManager.lookup_Up()
        }
    }
    /**
     遥控器向左
     */
    public func performLeft(){
        if !focusHidden {
            focusManager.lookup_Left()
        }
    }
    /**
     遥控器向右
     */
    public func performRight(){
        if !focusHidden {
            focusManager.lookup_Right()
        }
    }
    /**
     遥控器向下
     */
    public func performDown(){
        if !focusHidden {
            focusManager.lookup_Down()
        }
    }
    /**
     点击确认按钮
     */
    public func confirm() {
        
        if !focusHidden {
            displayDelegate?.confirm()
        }
        
    }
    
    /**
     返回
     */
    public func back(){
        
        if !focusHidden {
            displayDelegate?.back()
        }
    }
    /**
     指定焦点到view上
     
     - parameter view: 要指定焦点的view
     */
    public func setFocusForView(view:UIView?){
        
        if view != nil && !focusHidden{
            //TODO: 指定焦点
        }
    }

    //MARK:要交给系统处理的action
    /**
     音量调大
     */
    public func voiceUp(){
        
    }
    /**
     音量调小
     */
    public func voiceDown(){
        
    }
    //MARK:语音指令
    /**
     语音发送命令
     
     - parameter str: 翻译过来的文字
     */
    public func performOrderWithString(order:ExVROrder, str:String?){
        
    }

}
