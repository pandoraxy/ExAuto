//
//  ExFocusManager.swift
//  ExDisplay
//
//  Created by  mapbar_ios on 16/4/19.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit

let btnCornerRadius:CGFloat = 8 //这个成员将来要删掉，临时加上它

class ExFocusManager {
    
    /**
     焦点视图(私有常量)
     */
    private let focusView:UIView = UIView.init()
    /**
     当前选中的焦点()
     */
    var currentItem : UIView?
    //MARK: - Class Methods
    
    init() {
        setupFocusView()
    }
    //MARK:- Instance Methods
    private func setupFocusView() {
        
        focusView.backgroundColor = UIColor.clearColor()
        focusView.layer.cornerRadius = btnCornerRadius
        focusView.layer.borderWidth = 4
        focusView.layer.borderColor = UIColor.orangeColor().CGColor
        
    }
    
    /**
     focus移动到指定view上
     
     - parameter view: 选择了的view
     */
    func setFocusForView(view:UIView?) {
        
        if view != nil && view != currentItem {
            let delegateView = ExControlCenter.sharedInstance()?.displayControlDelegate?.secondScreenView
            
            if delegateView != nil {//当前有整体视图
                //把focus放在最上层
                if focusView.superview == delegateView! {//focus已加入delegateview
                    delegateView!.bringSubviewToFront(focusView)
                }else{
                    delegateView!.addSubview(focusView)
                }
                
                if !ExControlCenter.sharedInstance()!.focusHidden {//focus没被隐藏
                    moveFocusWithAnimation(view!)
                }else{//focus已经隐藏了
                    moveFocusWithoutAnimation(view!)
                    
                }
            }

        }
    }
    /**
     带动画的移动焦点
     
     - parameter view: 要移动到的view
     */
    func moveFocusWithAnimation(view:UIView){
        if currentItem != nil {//确实选了另外一个
            let originalFrame = currentItem!.frame
            let finalFrame = view.frame
            UIView.animateWithDuration(0.3, animations: {
                self.focusView.frame = originalFrame
                self.focusView.frame = finalFrame
                }, completion: { (complete) in
                    if(complete){
                        self.currentItem = view
                    }
            })
            
        }else if nil == currentItem{//当前没有选定的
            UIView.animateWithDuration(0.3, animations: {
                self.focusView.frame = view.frame
                }, completion: { (complete) in
                    if(complete){
                        self.currentItem = view
                    }
            })
        }

    }
    /**
     不带动画的移动焦点
     
     - parameter view: 要移动到的view
     */
    func moveFocusWithoutAnimation(view:UIView){
        
        focusView.frame = view.frame
        currentItem = view
    }
    /**
     向上查找
     */
     func lookup_Up() {
        let items = ExControlCenter.sharedInstance()?.displayControlDelegate?.secondScreenView?.subviews
        if nil != items {//当前有选中项
            //搜索策略：首先查找垂直最短间距；如果最短间距有多个，则选择水平最短间距那个控件作为查找对象
            //以后的向右、向左、向下策略相同，相应方向会有变化
            //所有的查找都以中心点作为查找依据
            var minVDistance = CGFloat.max//垂直最短间距
            var minHDistance = CGFloat.max//水平最短间距
            var nextItem:UIView? = currentItem //查找对象
            for item in items! {//遍历所有控件
                if item.center.y < currentItem!.center.y {//只查找上面的控件
                    if minVDistance >= fabs(item.center.y - currentItem!.center.y) {//垂直间距不大于最短间距，需要进一步判断
                        
                        if minVDistance > fabs(item.center.y - currentItem!.center.y) {//找到垂直更短间距
                            minVDistance = fabs(item.center.y - currentItem!.center.y)
                            minHDistance = CGFloat.max
                            nextItem = item
                        }else{//当前的垂直最短距离相同，则找到它们中的水平最短间距作为查找对象
                            if minHDistance > fabs(item.center.x - currentItem!.center.x) {
                                minHDistance = fabs(item.center.x - currentItem!.center.x)
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            if currentItem != nextItem {
                setFocusForView(nextItem)
            }
            
        }
    }
    /**
     向左查找
     标注同向上
     */
    func lookup_Left() {
        let items = ExControlCenter.sharedInstance()?.displayControlDelegate?.secondScreenView?.subviews

        if items != nil {
            var minVDistance = CGFloat.max
            var minHDistance = CGFloat.max
            var nextItem:UIView? = currentItem
            for item in items! {
                if item.center.x < currentItem!.center.x {
                    if minHDistance >= fabs(item.center.x - currentItem!.center.x) {
                        
                        if minHDistance > fabs(item.center.x - currentItem!.center.x) {
                            minHDistance = fabs(item.center.x - currentItem!.center.x)
                            
                            minVDistance = CGFloat.max
                            nextItem = item
                        }else{
                            if minVDistance > fabs(item.center.y - currentItem!.center.y) {
                                minVDistance = fabs(item.center.y - currentItem!.center.y)
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            if currentItem != nextItem {
                setFocusForView(nextItem)
            }
            
        }
    }
    /**
     向右查找
     标注同向上
     */
    func lookup_Right() {
        let items = ExControlCenter.sharedInstance()?.displayControlDelegate?.secondScreenView?.subviews

        if items != nil {
            var minVDistance = CGFloat.max
            var minHDistance = CGFloat.max
            var nextItem:UIView? = currentItem
            for item in items! {
                if item.center.x > currentItem!.center.x {
                    if minHDistance >= fabs(item.center.x - currentItem!.center.x) {
                        
                        if minHDistance > fabs(item.center.x - currentItem!.center.x) {
                            minHDistance = fabs(item.center.x - currentItem!.center.x)
                            
                            minVDistance = CGFloat.max
                            nextItem = item
                        }else{
                            if minVDistance > fabs(item.center.y - currentItem!.center.y) {
                                minVDistance = fabs(item.center.y - currentItem!.center.y)
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            if currentItem != nextItem {
                setFocusForView(nextItem)
            }
            
        }
    }
    /**
     向下查找
     标注同向上
     */
    func lookup_Down() {
        let items = ExControlCenter.sharedInstance()?.displayControlDelegate?.secondScreenView?.subviews
        if items != nil {
            var minVDistance = CGFloat.max
            var minHDistance = CGFloat.max
            var nextItem:UIView? = currentItem
            for item in items! {
                if item.center.y > currentItem!.center.y {
                    if minVDistance >= fabs(item.center.y - currentItem!.center.y) {
                        
                        if minVDistance > fabs(item.center.y - currentItem!.center.y) {
                            minVDistance = fabs(item.center.y - currentItem!.center.y)
                            
                            minHDistance = CGFloat.max
                            nextItem = item
                        }else{
                            if minHDistance > fabs(item.center.x - currentItem!.center.x) {
                                minHDistance = fabs(item.center.x - currentItem!.center.x)
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            
            if currentItem != nextItem {
                setFocusForView(nextItem)
            }
        }
    }
        


}
