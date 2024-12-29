//
//  URLComponentHandler.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation

enum NetworkURL {
    static let tripURL = URL(string: "http://apis.data.go.kr/B551011/TarRlteTarService/areaBasedList")
    static let weatherURL = URL(string: "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst")
}

// MARK: URLComponentable
protocol URLComponentable {
    func getURLComponents(page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents
}

class URLComponentHandler: URLComponentable {
    
    var urlKeys: URLKeyConfiguring
    
    init(urlKeys: URLKeyConfiguring = URLKeys()) {
        self.urlKeys = urlKeys
    }
    
    func getURLComponents(page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents {
        var components = URLComponents()
        if tripKey != nil && weatherKey == nil {
            let url = NetworkURL.tripURL
            components.percentEncodedQueryItems = urlKeys.getQueryItems(page: page, tripKey: tripKey)
            components.host = url?.host()
            components.scheme = url?.scheme
            components.path = url?.path() ?? ""
        }
        if weatherKey != nil && tripKey == nil {
            let url = NetworkURL.weatherURL
            components.percentEncodedQueryItems = urlKeys.getQueryItems(page: page, weatherKey: weatherKey)
            components.host = url?.host()
            components.scheme = url?.scheme
            components.path = url?.path() ?? ""
        }
        
        return components
    }
}
