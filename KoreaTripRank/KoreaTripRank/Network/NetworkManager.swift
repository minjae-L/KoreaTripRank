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

class MockURLProtocol: URLProtocol {
    
    enum NetworkType {
        case trip
        case weather
        
        var fileName: String {
            switch self {
            case .trip: return "MockTripData"
            case .weather: return "MockWeatherData"
            }
        }
    }
    
    enum ResponseType {
        case failure(Error)
        case success(HTTPURLResponse)
    }
    
    enum MockError: Error {
        case none
    }
    
    static var mockResponse: ResponseType!
    static var mockType: NetworkType!
    
    
    static func setMockType(type: NetworkType) {
        MockURLProtocol.mockType = type
    }
    
    static func setMockResponseWithFailure() {
        MockURLProtocol.mockResponse = .failure(MockError.none)
    }
    
    static func setMockResponseWithStatusCode(code: Int) {
        MockURLProtocol.mockResponse = .success(HTTPURLResponse(url: URL(string: "hi/bye")!,
                                                                statusCode: code,
                                                                httpVersion: nil,
                                                                headerFields: nil)!)
    }
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let response = setMockResponse()
        let mockData = setMockData()
        
        client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .allowed)
        
        client?.urlProtocol(self, didLoad: mockData!)
        
        self.client?.urlProtocolDidFinishLoading(self)
        
    }
    
    override func stopLoading() { }
    
    private func setMockResponse() -> HTTPURLResponse? {
        var response: HTTPURLResponse?
        
        switch MockURLProtocol.mockResponse {
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        case .success(let successResponse):
            response = successResponse
        default: 
            fatalError("No Mock Response")
            break
        }
        
        return response!
    }
    
    private func setMockData() -> Data? {
        return JsonLoader().data(fileName: MockURLProtocol.mockType.fileName)
    }
    
}

// MARK: NetworkManager
class NetworkManager {
    let components: URLComponentable
    let decoder: DataDecodable
    
    let session: Session
    
    init(components: URLComponentable = URLComponentHandler(),
                 decoder: DataDecodable = DecodeHandler(),
                 session: Session = Session.default) {
        self.components = components
        self.decoder = decoder
        self.session = session
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
        let request = session.request(url)
        
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


