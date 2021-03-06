//
//  Loader.swift
//  KMC
//
//  Created by Kofax on 29/08/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

import UIKit

public struct Loader {

    //==========================================================================================================
    // Feel free to edit these variables
    //==========================================================================================================
    public struct Settings {
        public static var BackgroundColor = UIColor(red: 227/255, green: 232/255, blue: 235/255, alpha: 1.0)
        public static var ActivityColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        public static var TextColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
        public static var FontName = "HelveticaNeue-Light"
        // Other possible stuff: ✓ ✓ ✔︎ ✕ ✖︎ ✘
        public static var SuccessColor = UIColor(red: 68/255, green: 118/255, blue: 4/255, alpha: 1.0)
        public static var FailColor = UIColor(red: 255/255, green: 75/255, blue: 56/255, alpha: 1.0)
        static var WidthDivision: CGFloat {
            get {
                if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
                    return  3.5
                } else {
                    return 1.6
                }
            }
        }
    }

    private static var instance: LoadingActivity?
    private static var hidingInProgress = false

    /// Disable UI stops users touch actions until EZLoadingActivity is hidden. Return success status
    public static func show(text: String, disableUI: Bool) -> Bool {
        guard instance == nil else {
            print("KMCLoadingActivity: You still have an active activity, please stop that before creating a new one")
            return false
        }

        guard topMostController != nil else {
            print("KMCLoadingActivity Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
            return false
        }

        instance = LoadingActivity(text: text, disableUI: disableUI)
        return true
    }

    public static func showWithDelay(text: String, disableUI: Bool, seconds: Double) -> Bool {
        let showValue = show(text, disableUI: disableUI)
        delay(seconds) { () -> () in
            hide()
        }
        return showValue
    }

    /// Returns success status
    public static func hide() {
        if !NSThread.currentThread().isMainThread {
            dispatch_async(dispatch_get_main_queue()) {
                instance?.hideLoadingActivity()
            }
        } else {
            instance?.hideLoadingActivity()
        }
    }

    private static func delay(seconds: Double, after: ()->()) {
        let queue = dispatch_get_main_queue()
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(time, queue, after)
    }

    private class LoadingActivity: UIView {
        var textLabel: UILabel!
        var activityView: UIActivityIndicatorView!
        var icon: UILabel!
        var UIDisabled = false

        convenience init(text: String, disableUI: Bool) {
            let width = UIScreen.ScreenWidth / Settings.WidthDivision
            let height = width / 3
            self.init(frame: CGRect(x: UIScreen.ScreenWidth/2 - width/2, y: UIScreen.ScreenHeight/2 - height/2, width: width, height: height))
            backgroundColor = Settings.BackgroundColor
            alpha = 1
            layer.cornerRadius = 8
            createShadow()

            let yPosition = frame.height/2 - 20

            activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activityView.frame = CGRect(x: 10, y: yPosition, width: 40, height: 40)
            activityView.color = Settings.ActivityColor
            activityView.startAnimating()

            textLabel = UILabel(frame: CGRect(x: 60, y: yPosition, width: width - 70, height: 40))
            textLabel.textColor = Settings.TextColor
            textLabel.font = UIFont(name: Settings.FontName, size: 30)
            textLabel.adjustsFontSizeToFitWidth = true
            textLabel.minimumScaleFactor = 0.25
            textLabel.textAlignment = NSTextAlignment.Center
            textLabel.text = text

            addSubview(activityView)
            addSubview(textLabel)

            topMostController!.view.addSubview(self)

            if disableUI {
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                UIDisabled = true
            }
        }

        func createShadow() {
            layer.shadowPath = createShadowPath().CGPath
            layer.masksToBounds = false
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSizeMake(0, 0)
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.5
        }

        func createShadowPath() -> UIBezierPath {
            let myBezier = UIBezierPath()
            myBezier.moveToPoint(CGPoint(x: -3, y: -3))
            myBezier.addLineToPoint(CGPoint(x: frame.width + 3, y: -3))
            myBezier.addLineToPoint(CGPoint(x: frame.width + 3, y: frame.height + 3))
            myBezier.addLineToPoint(CGPoint(x: -3, y: frame.height + 3))
            myBezier.closePath()
            return myBezier
        }

        func hideLoadingActivity() {
            hidingInProgress = true
            if UIDisabled {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
            hidingInProgress = false
            instance = nil
            self.removeFromSuperview()
        }
    }
}

private extension UIView {
    /// Extension: insert view.fadeTransition right before changing content
    func fadeTransition(duration: CFTimeInterval) {
        let animation: CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.addAnimation(animation, forKey: kCATransitionFade)
    }
}

private extension NSObject {
    func callSelectorAsync(selector: Selector, delay: NSTimeInterval) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(delay, target: self, selector: selector, userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
}

private extension UIScreen {
    class var Orientation: UIInterfaceOrientation {
        get {
            return UIApplication.sharedApplication().statusBarOrientation
        }
    }
    class var ScreenWidth: CGFloat {
        get {
            if UIInterfaceOrientationIsPortrait(Orientation) {
                return UIScreen.mainScreen().bounds.size.width
            } else {
                return UIScreen.mainScreen().bounds.size.height
            }
        }
    }
    class var ScreenHeight: CGFloat {
        get {
            if UIInterfaceOrientationIsPortrait(Orientation) {
                return UIScreen.mainScreen().bounds.size.height
            } else {
                return UIScreen.mainScreen().bounds.size.width
            }
        }
    }
}

private var topMostController: UIViewController? {
    var presentedVC = UIApplication.sharedApplication().keyWindow?.rootViewController
    while let pVC = presentedVC?.presentedViewController {
        presentedVC = pVC
    }

    return presentedVC
}

