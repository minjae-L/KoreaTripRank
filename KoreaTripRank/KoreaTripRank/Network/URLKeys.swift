//
//  URLKeys.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/30/24.
//

import Foundation

protocol URLKeyConfiguring {
    func getQueryItems(type: NetworkURLCase,
                       page: Int,
                       weatherKey: ConvertedLocationModel?,
                       tripKey: LocationDataModel?) -> [URLQueryItem]
}

extension URLKeyConfiguring {
    func getQueryItems(type: NetworkURLCase,
                       page: Int,
                       weatherKey: ConvertedLocationModel? = nil,
                       tripKey: LocationDataModel? = nil) -> [URLQueryItem] {
        return getQueryItems(type: type, page: page, weatherKey: weatherKey, tripKey: tripKey)
    }
}
	
struct MockURLKeys: URLKeyConfiguring {
    func getQueryItems(type: NetworkURLCase, page: Int, weatherKey: ConvertedLocationModel?, tripKey: LocationDataModel?) -> [URLQueryItem] {
        return []
    }
}

// Components에 들어가는 query 구성
struct URLKeys: URLKeyConfiguring {
    
    var calendarCalculation: CalendarCalculating
    var APIKey: APIKEYConfiguring
    
    private let mobileOS: String = "iOS"
    private let mobileAppName: String = "KoreaTripRank"
    
    init(calendarCalculation: CalendarCalculating = CalendarCalculation(), APIKey: APIKEYConfiguring = APIKEY()) {
        self.calendarCalculation = calendarCalculation
        self.APIKey = APIKey
    }
    
    func getQueryItems(type: NetworkURLCase, page: Int, weatherKey: ConvertedLocationModel?, tripKey: LocationDataModel?) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        switch type {
        case .trip:
            guard let tripKey = tripKey else {
                print("getQueryItems:: [ERROR] tripKey not prepared")
                return []
            }
            queryItems = [
                URLQueryItem(name: "serviceKey", value: APIKey.getKey()),
                URLQueryItem(name: "numOfRows", value: "50"),
                URLQueryItem(name: "MobileOS", value: mobileOS),
                URLQueryItem(name: "MobileApp", value: mobileAppName),
                URLQueryItem(name: "baseYm", value:  calendarCalculation.getBeforeMonthDateString(dateFormat: "yyyyMM")),
                URLQueryItem(name: "areaCd", value: String(tripKey.areaCode)),
                URLQueryItem(name: "signguCd", value: String(tripKey.sigunguCode)),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "pageNo", value: String(page))
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
            queryItems = [ URLQueryItem(name: "serviceKey", value: APIKey.getKey()),
                           URLQueryItem(name: "numOfRows", value: "60"),
                           URLQueryItem(name: "pageNo", value: String(page)),
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
