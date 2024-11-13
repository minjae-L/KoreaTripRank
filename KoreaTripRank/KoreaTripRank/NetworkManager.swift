//
//  NetworkManager.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/6/24.
//

import Foundation
import Alamofire

/*
 네트워크 매니저 하는일
 - url 구성
 - URLRequest 구성
 - 네트워크 통신
 - 디코딩
 */
enum NetworkError: Error {
    case decodingError
    case serverError(code: Int)
    case missingData
    case invalidURL
}
enum NetworkURLCase {
    case trip
    case weather
}
struct APIKEY {
    func getKey() -> String? {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) 
        else {
            return nil
        }
        return dict["APIKEY"] as? String
    }
}
class NetworkManager {
    let components: URLComponentable
    let decoder: DataDecodable
    
    init(components: URLComponentable, decoder: DataDecodable) {
        self.components = components
        self.decoder = decoder
    }
    
    func fetchData<T: Decodable>(type: T.Type) async throws -> T {
        guard let url = components.getURLComponents().url else {
            throw(NetworkError.invalidURL)
        }
        let request = AF.request(url)
        
        let response = await request.serializingDecodable(T.self).response
        guard (response.response)?.statusCode == 200 else {
            throw NetworkError.serverError(code: response.response?.statusCode ?? 0)
        }
        
        guard let data = response.value else {
            throw NetworkError.decodingError
        }
        return data
    }
    func fetchData<T: Decodable>(for URLCase: NetworkURLCase ,type: T.Type) async throws -> T {
        guard let url = components.getURLComponents(for: URLCase).url else {
            throw(NetworkError.invalidURL)
        }
        let request = AF.request(url)
        
        let response = await request.serializingDecodable(T.self).response
        guard (response.response)?.statusCode == 200 else {
            throw NetworkError.serverError(code: response.response?.statusCode ?? 0)
        }
        
        guard let data = response.value else {
            throw NetworkError.decodingError
        }
        return data
    }
}
protocol DataDecodable {
    func decode<T: Decodable>(type: T.Type, data: Data?) -> T?
}
class DecodeHandler: DataDecodable {
    func decode<T: Decodable>(type: T.Type, data: Data?) -> T? {
        guard let data = data else { return nil }
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("Success Decoded")
            return decoded
        } catch {
            print("decoded Error")
            return nil
        }
    }
}

protocol URLComponentable {
    func getURLComponents() -> URLComponents
    func getURLComponents(for type: NetworkURLCase) -> URLComponents
}
class URLComponentHandler: URLComponentable {
    let scheme = "https"
    let host = "apis.data.go.kr"
    let paths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    let mobileOS: String = "iOS"
    let mobileAppName: String = "KoreaTripRank"
    let tripPaths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    let weatherPaths: [String] = ["1360000","VilageFcstInfoService_2.0","getUltraSrtFcst"]
    
    func getURLComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/" + paths.joined(separator: "/")
        
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
            URLQueryItem(name: "numOfRows", value: "1"),
            URLQueryItem(name: "MobileOS", value: mobileOS),
            URLQueryItem(name: "MobileApp", value: mobileAppName),
            URLQueryItem(name: "baseYm", value: "202409"),
            URLQueryItem(name: "areaCd", value: "50"),
            URLQueryItem(name: "signguCd", value: "50130"),
            URLQueryItem(name: "_type", value: "json")
        ]
        return components
    }
    func getURLComponents(for type: NetworkURLCase) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        switch type {
        case .trip:
            components.path = "/" + tripPaths.joined(separator: "/")
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
                URLQueryItem(name: "numOfRows", value: "1"),
                URLQueryItem(name: "MobileOS", value: mobileOS),
                URLQueryItem(name: "MobileApp", value: mobileAppName),
                URLQueryItem(name: "baseYm", value: "202409"),
                URLQueryItem(name: "areaCd", value: "50"),
                URLQueryItem(name: "signguCd", value: "50130"),
                URLQueryItem(name: "_type", value: "json")
            ]
        case .weather:
            components.path = "/" + weatherPaths.joined(separator: "/")
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
                URLQueryItem(name: "numOfRows", value: "30"),
                URLQueryItem(name: "pageNo", value: "1"),
                URLQueryItem(name: "dataType", value: "JSON"),
                URLQueryItem(name: "base_date", value: "20241113"),
                URLQueryItem(name: "base_time", value: "0059"),
                URLQueryItem(name: "nx", value: "59"),
                URLQueryItem(name: "ny", value: "125")
            ]
        }
        return components
    }
}
