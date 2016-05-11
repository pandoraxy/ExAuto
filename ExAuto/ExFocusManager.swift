//
//  ExFocusManager.swift
//  ExDisplay
//
//  Created by  mapbar_ios on 16/4/19.
//  Copyright © 2016年 AppStudio. All rights reserved.
//

import UIKit

let ErrorMessage = "亲，目前只能让遵循ExViewDelegate协议的UIView处理焦点"
/// focus移动到新视图时的回调代理
public protocol ExFocusDelegate:class {
    
    func focus(focus:UIView,didSelectView view:UIView)
    
}
public protocol ExViewDelegate:class {
    /// 上次视图
    var lastFocusView:UIView? {get set}
    
}

public extension UIView {
        /// 可落焦点的次级视图
    var availableSubviews : [UIView]{
        return ExFocusManager.sharedInstance().getAvailableSubviews(self)
    }
        /// 可落焦点的上级视图
    var superView:UIView?{
        return ExFocusManager.sharedInstance().getSuperFocusForView(self)
    }
}

//MARK:以下为自定义的继承自系统的各种UIKit的类，只不过遵循了下ExViewDelegate协议
public class ExView : UIView, ExViewDelegate {
        /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExActionSheet:UIActionSheet,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExAlertView:UIAlertView,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExControl:UIControl, ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExCollectionViewCell:UICollectionViewCell,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExCollectionReusableView:UICollectionReusableView,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExButton:UIButton, ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExSegementedControl:UISegmentedControl,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
    
}
public class ExSlider:UISlider,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExStepper:UIStepper,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExDatePicker:UIDatePicker,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExPageControl:UIPageControl,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExRefreshControl:UIRefreshControl,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExSwitch:UISwitch,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExTextField:UITextField,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExImageView:UIImageView,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExInputView:UIInputView,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExPickerView:UIPickerView,ExViewDelegate{

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExPopoverBackgroundView:UIPopoverBackgroundView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExProgressView:UIProgressView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExScollView:UIScrollView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExCollectionView:UICollectionView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExTableView:UITableView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExTextView:UITextView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExSearchBar:UISearchBar,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}
public class ExStackView:UIStackView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExTabBar:UITabBar,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExTableViewCell:UITableViewCell,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExTableViewHeaderFooterView:UITableViewHeaderFooterView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExToolbar:UIToolbar,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExVisualEffectView:UIVisualEffectView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExWebView:UIWebView,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}

public class ExWindow:UIWindow,ExViewDelegate {

    /// 上次视图
    public var lastFocusView:UIView?
    
}
//MARK: 焦点管理器类
class ExFocusManager {

    private static var singleton:ExFocusManager?
    
    weak var focusDelegate:ExFocusDelegate?
    /**
     焦点视图
     */
    let focusView:UIView = UIView.init()
    
    /**
     当前选中的焦点()
     */
    
    var currentItem : UIView?
    //MARK: - Methods
    class func sharedInstance() -> ExFocusManager {
        
        if nil == singleton {
            
            singleton = ExFocusManager()
            
        }
        return singleton!
    }
    
    init() {
        setupFocusView()
    }
    //MARK:- Instance Methods
    private func setupFocusView() {
        
        focusView.backgroundColor = UIColor.clearColor()
        focusView.layer.cornerRadius = 8
        focusView.layer.borderWidth = 4
        focusView.layer.borderColor = UIColor.orangeColor().CGColor
        
    }
    
    /**
     focus移动到指定view上
     
     - parameter view: 选择了的view
     */
    func setFocusForView(view:UIView?, withAnimated animated:Bool) {
        
        if view is ExViewDelegate {
            if view != nil && view != currentItem {//确实选了另一个视图
                
                //把focus放在最上层
                if focusView.superview != UIApplication.sharedApplication().windows.last {//focus未出现
                    
                    UIApplication.sharedApplication().windows.last?.addSubview(focusView)
                }
                
                moveFocus(view!, withAnimated: animated)
                
            }
        }else{
            print(ErrorMessage)
        }
        
    }
    /**
     带动画的移动焦点
     
     - parameter view: 要移动到的view
     */
    private func moveFocus(view:UIView,withAnimated animated:Bool){
        
        let finalFrame = convertRectToSecondWindow(view)
        
        if let view = view as? ExViewDelegate {
            
            if currentItem != nil {//确实选了另外一个

                let originalFrame = convertRectToSecondWindow(currentItem!)
                
                if animated {
                    
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.focusView.frame = originalFrame
                        
                        self.focusView.frame = finalFrame
                        
                        }, completion: { complete in
                            
                            if complete {
                                
                                UIApplication.sharedApplication().windows.last?.bringSubviewToFront(self.focusView)
                                
                                view.lastFocusView = self.currentItem
                                
                                self.currentItem = view as? UIView
                                
                                
                                self.focusDelegate?.focus(self.focusView, didSelectView: (view as! UIView))
                                
                            }
                        }
                        
                    )
                }else{
                    UIApplication.sharedApplication().windows.last?.bringSubviewToFront(focusView)
                    focusView.frame = finalFrame
                    view.lastFocusView = currentItem
                    currentItem = view as? UIView
                    focusDelegate?.focus(focusView, didSelectView: (view as! UIView))
                    
                }
                
            }else if nil == currentItem{//当前没有选定的
                
                if animated {
                    UIApplication.sharedApplication().windows.last?.bringSubviewToFront(self.focusView)
                    UIView.animateWithDuration(0.3, animations: {
                        
                        self.focusView.frame = self.convertRectToSecondWindow(view as! UIView)
                        
                        }, completion: { complete in
                            if complete {
                                UIApplication.sharedApplication().windows.last?.bringSubviewToFront(self.focusView)
                                view.lastFocusView = self.currentItem
                                self.currentItem = view as? UIView
                                
                                self.focusDelegate?.focus(self.focusView, didSelectView: (view as! UIView))
                            }
                        }
                    )
                }else{
                    UIApplication.sharedApplication().windows.last?.bringSubviewToFront(focusView)
                    focusView.frame = finalFrame
                    view.lastFocusView = currentItem
                    currentItem = view as? UIView
                    focusDelegate?.focus(focusView, didSelectView: (view as! UIView))
                }
                
            }
        }else{
            print(ErrorMessage)
        }

    }
    
    private func convertRectToSecondWindow(view:UIView) -> CGRect{
        return UIApplication.sharedApplication().windows.last!.convertRect(view.frame, fromView: view.superView)
        
        
    }
    
    private func convertPointToSecondWindow(point:CGPoint,withView view:UIView) -> CGPoint{
        
        return UIApplication.sharedApplication().windows.last!.convertPoint(point, fromView: view.superView)
        
    }
    
    /**
     向上查找
     */
    func lookup_Up(animated animated:Bool) {
        
        if let items = (currentItem?.superView ?? currentItem?.superview)?.availableSubviews {//当前有选中项
            
            //搜索策略：首先查找垂直最短间距；如果最短间距有多个，则选择水平最短间距那个控件作为查找对象
            //以后的向右、向左、向下策略相同，相应方向会有变化
            //所有的查找都以中心点作为查找依据
            var minVDistance = CGFloat.max//垂直最短间距
            var minHDistance = CGFloat.max//水平最短间距
            var nextItem:UIView? = currentItem //查找对象
            for item in items {//遍历所有控件
                if convertPointToSecondWindow(item.center, withView: item).y < convertPointToSecondWindow(currentItem!.center, withView: currentItem!).y {//只查找上面的控件
                    let currentVSpace = fabs(convertPointToSecondWindow(item.center, withView: item).y - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).y)
                    if minVDistance >= currentVSpace {//垂直间距不大于最短间距，需要进一步判断
                        
                        if minVDistance > currentVSpace {//找到垂直更短间距
                            minVDistance = currentVSpace
                            minHDistance = CGFloat.max
                            nextItem = item
                        }else{//当前的垂直最短距离相同，则找到它们中的水平最短间距作为查找对象
                            let currentHSpace = fabs(convertPointToSecondWindow(item.center, withView: item).x - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x)
                            if minHDistance > currentHSpace {
                                minHDistance = currentHSpace
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            if currentItem != nextItem {
                setFocusForView(nextItem, withAnimated: animated)
            }
            
        }
        

    }
    /**
     向左查找
     标注同向上
     */
    func lookup_Left(animated animated:Bool) {
        
        if let items = (currentItem?.superView ?? currentItem?.superview)?.availableSubviews {
            var minVDistance = CGFloat.max
            var minHDistance = CGFloat.max
            var nextItem:UIView? = currentItem
            for item in items {
                if convertPointToSecondWindow(item.center, withView: item).x < convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x {
                    let currentHSpacing = fabs(convertPointToSecondWindow(item.center, withView: item).x - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x)
                    if minHDistance >= currentHSpacing {
                        
                        if minHDistance > fabs(convertPointToSecondWindow(item.center, withView: item).x - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x) {
                            minHDistance = fabs(convertPointToSecondWindow(item.center, withView: item).x - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x)
                            
                            minVDistance = CGFloat.max
                            nextItem = item
                        }else{
                            let currentVSpacing = fabs(convertPointToSecondWindow(item.center, withView: item).y - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).y)
                            if minVDistance > currentVSpacing {
                                minVDistance = currentVSpacing
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            if currentItem != nextItem {
                setFocusForView(nextItem, withAnimated: animated)
            }
            
        }
    }
    /**
     向右查找
     标注同向上
     */
    func lookup_Right(animated animated:Bool) {
        
        if let items = (currentItem?.superView ?? currentItem?.superview)?.availableSubviews {
            var minVDistance = CGFloat.max
            var minHDistance = CGFloat.max
            var nextItem:UIView? = currentItem
            for item in items {
                if convertPointToSecondWindow(item.center, withView: item).x > convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x {
                    let currentHSpacing = fabs(convertPointToSecondWindow(item.center, withView: item).x - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x)
                    if minHDistance >= currentHSpacing {
                        
                        if minHDistance > currentHSpacing {
                            minHDistance = currentHSpacing
                            
                            minVDistance = CGFloat.max
                            nextItem = item
                        }else{
                            let currentVSpacing = fabs(convertPointToSecondWindow(item.center, withView: item).y - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).y)
                            if minVDistance > currentVSpacing {
                                minVDistance = currentVSpacing
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            if currentItem != nextItem {
                setFocusForView(nextItem, withAnimated: animated)
            }
            
        }
    }
    /**
     向下查找
     标注同向上
     */
    func lookup_Down(animated animated:Bool) {
        
        if let items = (currentItem?.superView ?? currentItem?.superview)?.availableSubviews {
            var minVDistance = CGFloat.max
            var minHDistance = CGFloat.max
            var nextItem:UIView? = currentItem
            for item in items {
                if convertPointToSecondWindow(item.center, withView: item).y > convertPointToSecondWindow(currentItem!.center, withView: currentItem!).y {
                    let currentVSpacing = fabs(convertPointToSecondWindow(item.center, withView: item).y - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).y)
                    if minVDistance >= currentVSpacing {
                        
                        if minVDistance > currentVSpacing {
                            minVDistance = currentVSpacing
                            
                            minHDistance = CGFloat.max
                            nextItem = item
                        }else{
                            let currentHSpacing = fabs(convertPointToSecondWindow(item.center, withView: item).x - convertPointToSecondWindow(currentItem!.center, withView: currentItem!).x)
                            
                            
                            if minHDistance > currentHSpacing {
                                minHDistance = currentHSpacing
                                nextItem = item
                            }
                            
                        }
                    }
                    
                }
            }
            
            if currentItem != nextItem {
                setFocusForView(nextItem, withAnimated: animated)
            }
        }
    }
    
    func getSuperFocusForView(view:UIView?) -> UIView?{
        
        var superView = view?.superview
        
        while superView != nil {
            
            if superView! is ExViewDelegate {
                
                return superView
            }else{
                
                superView = superView?.superview
            }
        }
        
        return nil
    }
    
    func getAvailableSubviews(view:UIView?) -> [UIView]{
        
        var subViews = [UIView]()

        if view?.subviews.count > 0 {
            var find = false
            var i = 0
            while i < view!.subviews.count {
                let subView = view!.subviews[i]
                if subView is ExViewDelegate {
                    find = true
                    subViews.append(subView)
                }
                i += 1
            }
            if !find {
                i = 0
                while i < view!.subviews.count {
                    subViews = getAvailableSubviews(view!.subviews.first)
                    i += 1
                }
            }
        }
            
        
        
        return subViews
        
    }
    

}
