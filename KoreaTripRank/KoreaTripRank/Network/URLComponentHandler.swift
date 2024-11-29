//
//  URLComponentHandler.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation

// MARK: URLComponentable
protocol URLComponentable {
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents
}
extension URLComponentable {
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel? = nil, weatherKey: ConvertedLocationModel? = nil) -> URLComponents {
        return getURLComponents(for: type, page: page, tripKey: tripKey, weatherKey: weatherKey)
    }
}

class URLComponentHandler: URLComponentable {
    private let mobileOS: String = "iOS"
    private let mobileAppName: String = "KoreaTripRank"
    let calendarCalculation: CalendarCalculation
    let key = APIKEY()
    
    init() {
        self.calendarCalculation = CalendarCalculation()
    }
    
    private var currentDate: (baseDate: String, baseTime: String, baseDateYM: String) {
        return (calendarCalculation.getCurrentDateString(dateFormat: "yyyyMMdd"),
                calendarCalculation.getBeforeHalfHourDateString(dateFormat: "HHmm"),
                calendarCalculation.getBeforeMonthDateString(dateFormat: "yyyyMM"))
    }
    
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents {
        guard let url = type.getURL() else {
            print("getURLComponents:: url Error")
            return URLComponents()
        }
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host()
        components.path = url.path()
        
        switch type {
        case .trip:
            guard let areaCd = tripKey?.areaCode,
                  let sigunguCd = tripKey?.sigunguCode else {
                print("getURLComponents:: [ERROR] tripKey not prepared")
                return URLComponents()
            }
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: key.getKey()),
                URLQueryItem(name: "numOfRows", value: "50"),
                URLQueryItem(name: "MobileOS", value: mobileOS),
                URLQueryItem(name: "MobileApp", value: mobileAppName),
                URLQueryItem(name: "baseYm", value: currentDate.baseDateYM),
                URLQueryItem(name: "areaCd", value: String(areaCd)),
                URLQueryItem(name: "signguCd", value: String(sigunguCd)),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "pageNo", value: String(page))
            ]
        case .weather:
            guard let nx = weatherKey?.x,
                  let ny = weatherKey?.y else {
                print("getURLComponents:: [ERROR] weatherKey not prepared")
                return URLComponents()
            }
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: key.getKey()),
                URLQueryItem(name: "numOfRows", value: "60"),
                URLQueryItem(name: "pageNo", value: String(page)),
                URLQueryItem(name: "dataType", value: "JSON"),
                URLQueryItem(name: "base_date", value: currentDate.baseDate),
                URLQueryItem(name: "base_time", value: currentDate.baseTime),
                URLQueryItem(name: "nx", value: String(nx)),
                URLQueryItem(name: "ny", value: String(ny))
            ]
        }
        return components
    }
}
