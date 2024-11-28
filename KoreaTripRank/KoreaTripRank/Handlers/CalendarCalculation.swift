//
//  CalendarCalculation.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/27/24.
//

import Foundation

struct CalendarCalculation {
    
    func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter.string(from: Date())
    }
    
    func getAfterHourDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let afterHourDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        
        return dateFormatter.string(from: afterHourDate!) + "00"
    }
}
