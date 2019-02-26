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

@IBDesignable
class FormTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}


extension NSDate {
    
    func convertDateTime(time: TimeInterval) -> String {
        
        let format = DateFormatter()
        
        // Set locale is independent of the device's locale
        format.locale = Locale(identifier: "en_US_POSIX")
        
        format.dateStyle = .short
        format.timeStyle = .short
        format.dateFormat = "MM/dd HH:mm";
        let date = NSDate(timeIntervalSince1970: time)
        let dateStr = format.string(from: date as Date)
        return dateStr
        
    }
    
    func getDateNow() -> NSDate? {
        
        let now: Date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: now)
        
        return formatter.date(from: today) as NSDate?
        
    }
    
    func getDateTimeNow() -> NSDate? {
        
        let now: Date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let today = formatter.string(from: now)
        
        return formatter.date(from: today) as NSDate?
        
    }
    
    func convertTimeToTimeInterVal(time: String, format: String) -> TimeInterval? {
        
        let formatter = DateFormatter()
        
        //fix time for Twitter
        let localeStr = "us"
        formatter.locale = NSLocale(localeIdentifier: localeStr) as Locale
        
        formatter.dateFormat = format
        let date: NSDate? = formatter.date(from: time) as NSDate?
        
        return date?.timeIntervalSince1970
        
    }
    
    /* convert NSDate to String as given format */
    func format(_ format: String) ->String {
        
        let formater = DateFormatter()
        formater.dateFormat = format
        
        return formater.string(from: self as Date)
    }
}

extension Date {
    func format(_ format: String) -> String {
        let formater = DateFormatter()
        formater.dateFormat = format
        
        return formater.string(from: self)
    }
}


extension Date {
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hour ago" :
                "\(hour)" + " " + "hours ago"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute)" + " " + "minute ago" :
                "\(minute)" + " " + "minutes ago"
        } else if let second = interval.second, second > 0 {
            return second == 1 ? "\(second)" + " " + "second ago" :
                "\(second)" + " " + "seconds ago"
        } else {
            return "a moment ago"
        }
        
    }
}
