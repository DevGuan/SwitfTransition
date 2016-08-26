//
//  TransitionMaskUtils.swift
//  SwitfTransition
//
//  Created by DevGuan on 16/8/26.
//  Copyright © 2016年 com.ec. All rights reserved.
//

import Foundation
import UIKit

// 写一个扩展 计算蒙版以及动画位置
extension UIView{
    // 当前即将消失的页面
    func maskFrom(fromRect:CGRect ,duration:NSTimeInterval ,complete:()->() = {}){
        // 动画开启
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            // 设置完成后的操作block
            complete()
        }
        let maskLayer = CAShapeLayer()
        // 设置动画中心
        let fromCenter = CGPointMake(fromRect.origin.x + fromRect.size.width / 2.0, fromRect.origin.y + fromRect.size.height * 0.5)
        // 设置圆半径大小
        let fromRadius = min(fromRect.size.width * 0.5, fromRect.size.height * 0.5)
        // 设置路径
        let fromPath = UIBezierPath(arcCenter: fromCenter, radius: fromRadius, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        
        // 计算距离 取绝对值 考虑从小变大以及从大变小
        let r1 = sqrt(fromCenter.x * fromCenter.x + fromCenter.y * fromCenter.y)
        let r2 = sqrt((fromCenter.x - viewWidth)  * (fromCenter.x - viewWidth) + fromCenter.y * fromCenter.y)
        let r3Vlaue = (fromCenter.x - viewWidth)  * (fromCenter.x - viewWidth) + (fromCenter.y - viewHeight) * (fromCenter.y - viewHeight)
        let r3 = sqrt(r3Vlaue)
        let r4 = sqrt(fromCenter.x * fromCenter.x + (fromCenter.y - viewHeight) * (fromCenter.y - viewHeight))
        // 取最大值
        let toRadius = max(max(max(r1, r2), r3), r4)
        
        let toPath = UIBezierPath(arcCenter: fromCenter, radius: toRadius, startAngle: 0, endAngle: CGFloat(M_PI)*2, clockwise: true)
        maskLayer.path = toPath.CGPath
        
        // 路径变换的动画
        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.duration = duration
        basicAnimation.fromValue = fromPath.CGPath
        basicAnimation.toValue = toPath.CGPath
        basicAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        maskLayer.addAnimation(basicAnimation, forKey: "pathMask")
        
        // 设置蒙版动画
        self.layer.mask = maskLayer
        CATransaction.commit()
        
    }
    // 下一个出现的页面
    func maskTo(toRect:CGRect, duration:NSTimeInterval ,complete:()->() = {}){
        // layer 图层动画
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            complete()
        }
        let maskLayer = CAShapeLayer()
        let toCenter = CGPointMake(toRect.origin.x + toRect.size.width / 2.0, toRect.origin.y + toRect.size.height / 2)
        let toRadius:CGFloat = 0.001
        let toPath = UIBezierPath(arcCenter: toCenter, radius: toRadius, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        
        let r1 = sqrt(toCenter.x * toCenter.x + toCenter.y * toCenter.y)
        let r2 = sqrt((toCenter.x - viewWidth)  * (toCenter.x - viewWidth) + toCenter.y * toCenter.y)
        let r3Vlaue = (toCenter.x - viewWidth)  * (toCenter.x - viewWidth) + (toCenter.y - viewHeight) * (toCenter.y - viewHeight)
        let r3 = sqrt(r3Vlaue)
        let r4 = sqrt(toCenter.x * toCenter.x + (toCenter.y - viewHeight) * (toCenter.y - viewHeight))
        let fromRadius = max(max(max(r1,r2),r3),r4)
        
        let fromPath = UIBezierPath(arcCenter: toCenter, radius: fromRadius, startAngle: 0, endAngle: CGFloat(M_PI)*2, clockwise: true)
        
        maskLayer.path = toPath.CGPath
        
        let basicAnimation = CABasicAnimation(keyPath: "path")
        basicAnimation.duration = duration
        basicAnimation.fromValue = fromPath.CGPath
        basicAnimation.toValue = toPath.CGPath
        
        maskLayer.addAnimation(basicAnimation, forKey: "pathMask")
        self.layer.mask = maskLayer
        CATransaction.commit()
    }
    // 添加背景虚化效果
    func blurScreenShot(blurRadius:CGFloat)->UIImage?{
        guard self.superview != nil else{
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        // 获取当前截图
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let blur = CIFilter(name: "CIGaussianBlur") else{
            return nil
        }
        blur.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        let ciContext = CIContext(options: nil)
        let result = blur.valueForKey(kCIInputImageKey) as! CIImage!
        let boudingRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let cgImage = ciContext.createCGImage(result, fromRect: boudingRect)
        let filterImage = UIImage(CGImage: cgImage)
        return filterImage
    }
}