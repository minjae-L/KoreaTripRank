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
    func getSixHourStringArray(fcstTime: String) -> [String]
}

struct CalendarCalculation: CalendarCalculating {
    
    private static var dateFormatter = DateFormatter()
    
    func getCurrentDateString(dateFormat: String) -> String {
        CalendarCalculation.dateFormatter.dateFormat = dateFormat
        return CalendarCalculation.dateFormatter.string(from: Date())
    }
    
    func getAfterHourDateString(dateFormat: String) -> String {
        guard let afterHourDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) else { return "" }
        CalendarCalculation.dateFormatter.dateFormat = dateFormat
        return CalendarCalculation.dateFormatter.string(from: afterHourDate) + "00"
    }
    
    func getBeforeHalfHourDateString(dateFormat: String) -> String {
        guard let beforeHalfHour = Calendar.current.date(byAdding: .minute, value: -30, to: Date()) else { return "" }
        CalendarCalculation.dateFormatter.dateFormat = dateFormat
        return CalendarCalculation.dateFormatter.string(from: beforeHalfHour)
    }
    
    func getBeforeMonthDateString(dateFormat: String) -> String {
        guard let beforeMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else { return "" }
        CalendarCalculation.dateFormatter.dateFormat = dateFormat
        return CalendarCalculation.dateFormatter.string(from: beforeMonthDate)
    }
    // 기준시간으로 부터 6시간 뒤까지 시간 문자열 배열로 구하기
    func getSixHourStringArray(fcstTime: String) -> [String] {
        var output = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        guard let baseTime = dateFormatter.date(from: fcstTime) else { return [] }
        for i in 0..<6 {
            let time = Calendar.current.date(byAdding: .hour, value: i, to: baseTime)
            output.append(dateFormatter.string(from: time!))
        }
        return output
    }
}
