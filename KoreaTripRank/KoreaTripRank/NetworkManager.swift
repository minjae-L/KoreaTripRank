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
    func getKey() {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist") else { return }
        guard let dict = NSDictionary(contentsOf: url) else { return }
        print("APIKEY")
        print(dict["APIKEY"] as? String)
    }
}
class NetworkManager {
    let components: URLComponentable
    let decoder: DataDecodable
    
    init(components: URLComponentable, decoder: DataDecodable) {
        self.components = components
        self.decoder = decoder
    }
    
    func fetchData<T: Decodable>(type: T.Type) async throws -> T? {
        try await withUnsafeThrowingContinuation { continuation in
            guard let url = components.getURLComponents().url else {
                print("url Error")
                return
            }
            AF.request(url, method: .get).validate().response {[weak self] response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: self?.decoder.decode(type: type, data: data))
                    return
                case .failure(let error):
                    print(error.localizedDescription)
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    func fetchData2<T: Decodable>(type: T.Type) async throws -> T? {
        guard let url = components.getURLComponents().url else {
            print("url Error")
            return nil
        }
        return try await AF.request(url).serializingDecodable(T.self).value
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
            URLQueryItem(name: "serviceKey", value: "BLSSs%2FqV7vhukX%2Bxy4ts3XEuFU6UVBP6EuwoUxoEkW%2FLMRW27dBTbJXTKUhWeWy9bNidunqwB9Gb8p0Gm3FTRw%3D%3D"),
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
