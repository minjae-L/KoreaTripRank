//
//  CalendarCalculation.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/27/24.
//

import Foundation

protocol CalendarCalculating {
    func getCurrentDateString(dateFormat: String) -> String
    func getAfterHourDateString(dateFormat: String) -> String
    func getBeforeHalfHourDateString(dateFormat: String) -> String
    func getBeforeMonthDateString(dateFormat: String) -> String
}

struct CalendarCalculation: CalendarCalculating {
    let dateFormatter: DateFormatter
    
    init() {
        self.dateFormatter = DateFormatter()
    }
    
    func getCurrentDateString(dateFormat: String) -> String {
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: Date())
    }
    
    func getAfterHourDateString(dateFormat: String) -> String {
        dateFormatter.dateFormat = dateFormat
        let afterHourDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        
        return dateFormatter.string(from: afterHourDate!) + "00"
    }
    
    func getBeforeHalfHourDateString(dateFormat: String) -> String {
        dateFormatter.dateFormat = dateFormat
        let beforeHalfHour = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
        
        return dateFormatter.string(from: beforeHalfHour)
    }
    
    func getBeforeMonthDateString(dateFormat: String) -> String {
        dateFormatter.dateFormat = dateFormat
        let beforeMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        
        return dateFormatter.string(from: beforeMonthDate)
    }
}

struct MockCalendarCalculation: CalendarCalculating {
    func getCurrentDateString(dateFormat: String) -> String {
        return ""
    }
    
    func getAfterHourDateString(dateFormat: String) -> String {
        return ""
    }
    
    func getBeforeHalfHourDateString(dateFormat: String) -> String {
        return ""
    }
    
    func getBeforeMonthDateString(dateFormat: String) -> String {
        return ""
    }
}
