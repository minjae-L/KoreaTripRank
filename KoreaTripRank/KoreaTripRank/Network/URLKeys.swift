//
//  URLKeys.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/30/24.
//

import Foundation

// Components에 들어가는 query 구성
struct URLKeys {
    private let calendarCalculation: CalendarCalculation
    private let APIKEY: APIKEY
    private let mobileOS: String = "iOS"
    private let mobileAppName: String = "KoreaTripRank"
    
    init(calendarCalculation: CalendarCalculation, APIKEY: APIKEY) {
        self.calendarCalculation = calendarCalculation
        self.APIKEY = APIKEY
    }
    
    func getQueryItems(type: NetworkURLCase, pageNo: Int, weatherKey: ConvertedLocationModel? = nil, tripKey: LocationDataModel? = nil) -> [URLQueryItem] {
        
        var queryItems = [URLQueryItem]()
        
        switch type {
        case .trip:
            guard let tripKey = tripKey else {
                print("getQueryItems:: [ERROR] tripKey not prepared")
                return []
            }
            queryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY.getKey()),
                URLQueryItem(name: "numOfRows", value: "50"),
                URLQueryItem(name: "MobileOS", value: mobileOS),
                URLQueryItem(name: "MobileApp", value: mobileAppName),
                URLQueryItem(name: "baseYm", value:  calendarCalculation.getBeforeMonthDateString(dateFormat: "yyyyMM")),
                URLQueryItem(name: "areaCd", value: String(tripKey.areaCode)),
                URLQueryItem(name: "signguCd", value: String(tripKey.sigunguCode)),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "pageNo", value: String(pageNo))
            ]
        case .weather:
            guard let weatherKey = weatherKey else {
                print("getQueryItems:: [ERROR] weatherKey not prepared")
                return []
            }
            guard let nx = weatherKey.x,
                  let ny = weatherKey.y else {
                print("getQueryItems:: [ERROR] weatherKey.x .y is nil")
                return []
            }
            queryItems = [ URLQueryItem(name: "serviceKey", value: APIKEY.getKey()),
                           URLQueryItem(name: "numOfRows", value: "60"),
                           URLQueryItem(name: "pageNo", value: String(pageNo)),
                           URLQueryItem(name: "dataType", value: "JSON"),
                           URLQueryItem(name: "base_date", value: calendarCalculation.getCurrentDateString(dateFormat: "yyyyMMdd")),
                           URLQueryItem(name: "base_time", value: calendarCalculation.getBeforeHalfHourDateString(dateFormat: "HHmm")),
                           URLQueryItem(name: "nx", value: String(nx)),
                           URLQueryItem(name: "ny", value: String(ny))
            ]
        }
        
        return queryItems
    }
}
