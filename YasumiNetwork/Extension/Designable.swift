//
//  DesignableButton.swift
//  InternalNewsManager
//
//  Created by Tran Quang Minh on 2/9/17.
//  Copyright © 2017 Tribal Media House.inc. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor.clear
        }
        set (color) {
            self.layer.borderColor = color.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return 0
        }
        set (width) {
            
            self.layer.borderWidth = width
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return 0
        }
        set (cornerRadius) {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var topEdge: UIColor {
        get {
            return UIColor.clear
        }
        set (color) {
            let topEdge = CALayer()
            topEdge.backgroundColor = color.cgColor
            topEdge.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 0.5)
            self.layer.addSublayer(topEdge)
        }
    }
    
    @IBInspectable var bottomEdge: UIColor {
        get {
            return UIColor.clear
        }
        set (color) {
            let bottomEdge = CALayer()
            bottomEdge.backgroundColor = color.cgColor
            bottomEdge.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: 0.5)
            self.layer.addSublayer(bottomEdge)
        }
    }
}

extension UIButton {
    func underlineText(text: String, color: UIColor?) {
        var yourAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue) : NSUnderlineStyle.single.rawValue]
        if color != nil {
            
            yourAttributes = [
                NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): color as Any,
                NSAttributedString.Key(rawValue: NSAttributedString.Key.underlineStyle.rawValue): NSUnderlineStyle.single.rawValue]
        }
        let attributeString = NSMutableAttributedString(string: text, attributes: yourAttributes)
        self.setAttributedTitle(attributeString, for: .normal)
    }
    
}

