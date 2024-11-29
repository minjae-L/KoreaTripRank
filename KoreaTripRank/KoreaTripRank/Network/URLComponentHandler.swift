//
//  URLComponentHandler.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation

// Components에 들어가는 query 구성
struct URLKeys {
    private let calendarCalculation: CalendarCalculation
    private let APIKEY: APIKEY
    var type: NetworkURLCase?
    private let mobileOS: String = "iOS"
    private let mobileAppName: String = "KoreaTripRank"
    
    init(calendarCalculation: CalendarCalculation, APIKEY: APIKEY) {
        self.calendarCalculation = calendarCalculation
        self.APIKEY = APIKEY
    }
    
    func getQueryItems(pageNo: Int, weatherKey: ConvertedLocationModel?, tripKey: LocationDataModel?) -> [URLQueryItem] {
        guard let type = self.type else {
            print("type is nil")
            return []
        }
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
            queryItems = [ URLQueryItem(name: "serviceKey", value: APIKEY.getKey()),
                           URLQueryItem(name: "numOfRows", value: "60"),
                           URLQueryItem(name: "pageNo", value: String(pageNo)),
                           URLQueryItem(name: "dataType", value: "JSON"),
                           URLQueryItem(name: "base_date", value: calendarCalculation.getCurrentDateString(dateFormat: "yyyyMMdd")),
                           URLQueryItem(name: "base_time", value: calendarCalculation.getBeforeHalfHourDateString(dateFormat: "HHmm")),
                           URLQueryItem(name: "nx", value: String(weatherKey.x!)),
                           URLQueryItem(name: "ny", value: String(weatherKey.y!))
            ]
        }
        
        return queryItems
    }
}

enum NetworkURLCase: String {
    case trip = "http://apis.data.go.kr/B551011/TarRlteTarService/areaBasedList"
    case weather = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
    
    func getURL() -> URL? {
        return URL(string: self.rawValue)
    }
}

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
    var urlKeys: URLKeys
    
    init(urlKeys: URLKeys = URLKeys(calendarCalculation: CalendarCalculation(), APIKEY: APIKEY())) {
        self.urlKeys = urlKeys
    }
    
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents {
        urlKeys.type = type
        guard let url = type.getURL() else {
            print("getURLComponents:: url Error")
            return URLComponents()
        }
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host()
        components.path = url.path()
        components.percentEncodedQueryItems = urlKeys.getQueryItems(pageNo: page, weatherKey: weatherKey, tripKey: tripKey)

        return components
    }
}
