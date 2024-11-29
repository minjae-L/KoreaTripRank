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

enum NetworkURLCase: String {
    case trip = "http://apis.data.go.kr/B551011/TarRlteTarService/areaBasedList"
    case weather = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
    
    func getURL() -> URL? {
        return URL(string: self.rawValue)
    }
}

// MARK: NetworkManager
class NetworkManager {
    let components: URLComponentable
    let decoder: DataDecodable
    static let shared = NetworkManager(components: URLComponentHandler(), decoder: DecodeHandler())
    
    private init(components: URLComponentable, decoder: DataDecodable) {
        self.components = components
        self.decoder = decoder
    }
    
    func fetchData<T: Decodable>(urlCase URLCase: NetworkURLCase,
                                 tripKey: LocationDataModel? = nil,
                                 weatherKey: ConvertedLocationModel? = nil,
                                 type: T.Type,
                                 page: Int) async throws -> T {
        var urlComponents = URLComponents()
        switch URLCase {
        case .trip:
            urlComponents = components.getURLComponents(for: .trip, page: page, tripKey: tripKey)
        case .weather:
            urlComponents = components.getURLComponents(for: .weather, page: page, weatherKey: weatherKey)
        }
        guard let url = urlComponents.url else {
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


