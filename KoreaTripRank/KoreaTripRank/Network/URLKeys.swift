//
//  URLKeys.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/30/24.
//

import Foundation

protocol URLKeyConfiguring {
    func getQueryItems(page: Int,
                       weatherKey: ConvertedLocationModel?,
                       tripKey: LocationDataModel?) -> [URLQueryItem]
}

extension URLKeyConfiguring {
    func getQueryItems(page: Int,
                       weatherKey: ConvertedLocationModel? = nil,
                       tripKey: LocationDataModel? = nil) -> [URLQueryItem] {
        return getQueryItems(page: page, weatherKey: weatherKey, tripKey: tripKey)
    }
}
	
struct MockURLKeys: URLKeyConfiguring {
    func getQueryItems(page: Int, weatherKey: ConvertedLocationModel? = nil, tripKey: LocationDataModel? = nil) -> [URLQueryItem] {
        return []
    }
}

// Components에 들어가는 query 구성
struct URLKeys: URLKeyConfiguring {
    	
    var calendarCalculation: CalendarCalculating
    
    enum QueryDefaultKey {
        static let mobileOS = "iOS"
        static let mobileAppName = "KoreaTripRank"
        static let dataType = "JSON"
        static let numOfRows = "60"
    }
    init(calendarCalculation: CalendarCalculating = CalendarCalculation()) {
        self.calendarCalculation = calendarCalculation
    }
    
    func getQueryItems(page: Int, weatherKey: ConvertedLocationModel? = nil, tripKey: LocationDataModel? = nil) -> [URLQueryItem] {
        
        var queryItems = [URLQueryItem]()
        
        if weatherKey != nil && tripKey == nil { queryItems = getWeatherQueryItems(page: page, weatherKey: weatherKey!)}
        if tripKey != nil && weatherKey == nil { queryItems = getTripQueryItems(page: page, tripKey: tripKey!)}
        
        return queryItems
    }
    
    private func getTripQueryItems(page: Int, tripKey: LocationDataModel) -> [URLQueryItem] {
        return [URLQueryItem(name: "serviceKey", value: APIKEY.key),
                URLQueryItem(name: "numOfRows", value: QueryDefaultKey.numOfRows),
                URLQueryItem(name: "MobileOS", value: QueryDefaultKey.mobileOS),
                URLQueryItem(name: "MobileApp", value: QueryDefaultKey.mobileAppName),
                URLQueryItem(name: "baseYm", value:  calendarCalculation.getBeforeMonthDateString(dateFormat: "yyyyMM")),
                URLQueryItem(name: "areaCd", value: String(tripKey.areaCode)),
                URLQueryItem(name: "signguCd", value: String(tripKey.sigunguCode)),
                URLQueryItem(name: "_type", value: QueryDefaultKey.dataType),
                URLQueryItem(name: "pageNo", value: String(page))]
    }
    
    private func getWeatherQueryItems(page: Int, weatherKey: ConvertedLocationModel) -> [URLQueryItem] {
        guard let nx = weatherKey.x,
              let ny = weatherKey.y else { return [] }
        
        return [URLQueryItem(name: "serviceKey", value: APIKEY.key),
                URLQueryItem(name: "numOfRows", value: QueryDefaultKey.numOfRows),
                URLQueryItem(name: "pageNo", value: String(page)),
                URLQueryItem(name: "dataType", value: QueryDefaultKey.dataType),
                URLQueryItem(name: "base_date", value: calendarCalculation.getCurrentDateString(dateFormat: "yyyyMMdd")),
                URLQueryItem(name: "base_time", value: calendarCalculation.getBeforeHalfHourDateString(dateFormat: "HHmm")),
                URLQueryItem(name: "nx", value: String(nx)),
                URLQueryItem(name: "ny", value: String(ny))]
    }
}
