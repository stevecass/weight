//
//  WeighIn.swift
//  layout_tests
//
//  Created by Steven Cassidy on 4/15/15.
//  Copyright (c) 2015 Steven Cassidy. All rights reserved.
//
import Foundation

struct WeighIn {
    var date: NSDate
    var weight: Double
    init(dstr:String, w:String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        date = formatter.dateFromString(dstr)!
        weight = (w as NSString).doubleValue
    }
}
