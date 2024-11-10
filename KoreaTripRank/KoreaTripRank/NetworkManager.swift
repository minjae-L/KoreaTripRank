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
    
    func fetchData<T: Decodable>(type: T.Type) async throws -> Result<T, AFError> {
        guard let url = components.getURLComponents().url else {
            print("invalidURL")
            return .failure(AFError.invalidURL(url: ""))
        }
        do {
            let data = try await AF.request(url).serializingDecodable(T.self).value
            return .success(data)
        } catch {
            return .failure(error as! AFError)
        }
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
}
class URLComponentHandler: URLComponentable {
    let scheme = "https"
    let host = "apis.data.go.kr"
    let paths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    let mobileOS: String = "iOS"
    let mobileAppName: String = "KoreaTripRank"
    
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
}
