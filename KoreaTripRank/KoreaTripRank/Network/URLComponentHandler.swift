//
//  URLComponentHandler.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation

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
        guard let url = type.getURL() else {
            print("getURLComponents:: url Error")
            return URLComponents()
        }
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host()
        components.path = url.path()
        components.percentEncodedQueryItems = urlKeys.getQueryItems(type: type, pageNo: page, weatherKey: weatherKey, tripKey: tripKey)

        return components
    }
}
