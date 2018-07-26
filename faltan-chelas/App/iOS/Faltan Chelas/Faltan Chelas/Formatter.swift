//
//  VariablesAndFormatters.swift
//  nun2x3
//
//  Created by Jose De Jesus Garfias Lopez on 12/11/15.
//  Copyright © 2015 Jose De Jesus Garfias Lopez. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)];
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character);
    }
    
    subscript (r: Range<Int>) -> String {
        return substring(with: (characters.index(startIndex, offsetBy: r.lowerBound) ..< characters.index(startIndex, offsetBy: r.upperBound)));
    }
    
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {
    func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    fileprivate func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
}

extension Date {
    
    func isEqualDate(_ dateToCompare : Date) -> Bool {
        var isEqualTo = false;
        if self.compare(dateToCompare) == ComparisonResult.orderedSame{
            isEqualTo = true;
        }
        return isEqualTo;
    }
    
    
    func isGreaterThanDate(_ dateToCompare : Date) -> Bool {
        var isGreater = false;
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending{
            isGreater = true;
        }
        return isGreater;
    }
    
    func isLessThanDate(_ dateToCompare : Date) -> Bool {
        var isLess = false;
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending{
            isLess = true;
        }
        return isLess;
    }
    
    
    func addDays(_ daysToAdd : Int) -> Date {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24;
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays);
        return dateWithDaysAdded;
    }
    
    
    func addHours(_ hoursToAdd : Int) -> Date {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60;
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours);
        return dateWithHoursAdded;
    }
    
    var forServer: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
    
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

class Formatter {
    
    
    //Formatters:
    var Porcent:NumberFormatter{
        let formatter =  NumberFormatter();
        formatter.numberStyle = NumberFormatter.Style.percent;
        formatter.maximumFractionDigits = 1;
        formatter.multiplier = 1.0;
        formatter.percentSymbol = "%";
        return formatter;
    }
    var Date: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var LocalDate: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var DateForSave: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "dd/MM/yy HH:mm";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var Number: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumSignificantDigits = 2;
        return formatter
    };
    
    var Currency: NumberFormatter {
        let formatter = NumberFormatter();
        formatter.numberStyle = .currency;
        return formatter;
    };
    
    var LocalFromISO: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.locale = Locale.current;
        return formatter;
    }
    
    var ToISO: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter;
    }
    
    var DatePretty: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "dd/MMMM/YYYY";
        formatter.locale = Locale.current;
        return formatter;
    };
    var HourPretty: DateFormatter{
        let formatter = DateFormatter();
        formatter.dateFormat = "HH:mm";
        formatter.locale = Locale.current;
        return formatter;
    };
    
    var DateShortOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.timeZone = TimeZone.autoupdatingCurrent;
        formatter.dateFormat = "dd/MMM/YY";
        
        return formatter;
    };
    
    var DateMonthOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "MMMM";
        return formatter;
    };
    
    var DateDayOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "dd";
        return formatter;
    };
    
    var DateHourOnly: DateFormatter{
        let formatter = DateFormatter();
        formatter.locale = Locale.current;
        formatter.dateFormat = "HH";
        return formatter;
    };
    
    func ParseMomentDate(_ date: String) -> Foundation.Date{
        var dateString:String = "";
        
        for index in 1...5 {
            print("\(index) times 5 is \(index * 5)")
        }
        
        
        for i in 0..<date.characters.count {
            if(date[i] == "T"){
                dateString += " ";
            }else if(date[i] == "."){
                break;
            }else{
                dateString += date[i];
            }
        }
        if let DateISO = ToISO.date(from: dateString) {
            let strlocal = LocalFromISO.string(from: DateISO);
            if let DateToReturn = Date.date(from: strlocal) {
                return DateToReturn;
            }else{
                print("Could not parse date")
            }
        } else {
            print("Could not parse date")
        }
        return Foundation.Date();
    }
    
    func ParseMoment(_ date: String) -> Foundation.Date{
        var dateString:String = "";
        for i in 0..<date.characters.count {
            if(date[i] == "T"){
                dateString += " ";
            }else if(date[i] == "."){
                break;
            }else{
                dateString += date[i];
            }
        }
        return Date.date(from: dateString)!;
    }
    
    
    
    func FirstDayOfWeek(_ date: Foundation.Date) -> Foundation.Date {
        
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .weekOfMonth], from: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.weekday = 2;
        return calendar.date(from: dateComponents)!
    }
    
    
    func FirstDayOfMonth(_ date: Foundation.Date) -> Foundation.Date {
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .weekOfMonth], from: date);
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        dateComponents.day = 1;
        return calendar.date(from: dateComponents)!
    }
    
    func Today() ->Foundation.Date {
        
        var calendar = Calendar.current;
        calendar.timeZone = TimeZone.current;
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Foundation.Date());
        dateComponents.hour = 0;
        dateComponents.minute = 0;
        dateComponents.second = 0;
        return calendar.date(from: dateComponents)!
        
    }
    
    func formatTimeInSec(_ totalSeconds: Int) -> String {
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        let strHours = hours > 9 ? String(hours) : "0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        
        if hours > 0 {
            return "\(strHours):\(strMinutes):\(strSeconds)"
        }
        else {
            return "\(strMinutes):\(strSeconds)"
        }
    }
    
    init(){
    }
}

