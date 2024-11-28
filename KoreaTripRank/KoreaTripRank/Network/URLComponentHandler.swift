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
    private let scheme = "https"
    private let host = "apis.data.go.kr"
    private let paths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    private let mobileOS: String = "iOS"
    private let mobileAppName: String = "KoreaTripRank"
    private let tripPaths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    private let weatherPaths: [String] = ["1360000","VilageFcstInfoService_2.0","getUltraSrtFcst"]
    let calendarCalculation: CalendarCalculation
    
    init(calendarCalculation: CalendarCalculation) {
        self.calendarCalculation = calendarCalculation
    }
    
    private var currentDate: (baseDate: String, baseTime: String, baseDateYM: String) {
        return (calendarCalculation.getCurrentDateString(dateFormat: "yyyyMMdd"),
                calendarCalculation.getBeforeHalfHourDateString(dateFormat: "HHmm"),
                calendarCalculation.getBeforeMonthDateString(dateFormat: "yyyyMM"))
    }
    
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        
        switch type {
        case .trip:
            guard let areaCd = tripKey?.areaCode,
                  let sigunguCd = tripKey?.sigunguCode else {
                return URLComponents()
            }
            components.path = "/" + tripPaths.joined(separator: "/")
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
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
                return URLComponents()
            }
            components.path = "/" + weatherPaths.joined(separator: "/")
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
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
