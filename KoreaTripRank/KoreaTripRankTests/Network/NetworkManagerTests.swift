//
//  NetworkManagerTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 12/3/24.
//

import XCTest
import Alamofire
@testable import KoreaTripRank

final class NetworkManagerTests: XCTestCase {
    
    var sut: NetworkManager!
    
    override func setUpWithError() throws {
    }
    
    func test_fetchData호출시_관광지_데이터가성공적으로불러오는지() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .trip)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]

        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        let expectationResult = JsonLoader().load(type: TripNetworkResponse.self, fileName: "MockTripData")
        let result = try await sut.fetchData(urlCase: .trip,
                                             tripKey: LocationDataModel(areaName: "",
                                                                        sigunguName: "",
                                                                        areaCode: 0,
                                                                        sigunguCode: 0),
                                             type: TripNetworkResponse.self,
                                             page: 1)
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.response.responseBody.items.item.count, expectationResult?.response.responseBody.items.item.count)
    }
    
    func test_fetchData호출시_날씨_데이터가성공적으로불러오는지() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .weather)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        
        // when
        let expectationResult = JsonLoader().load(type: WeatherNetworkResponse.self, fileName: "MockWeatherData")
        let result = try await sut.fetchData(urlCase: .weather,
                                             weatherKey: ConvertedLocationModel(lat: 0,
                                                                                lng: 0,
                                                                                x: 0,
                                                                                y: 0),
                                             type: WeatherNetworkResponse.self,
                                             page: 1)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.response.responseBody?.items.item.count,
                       expectationResult?.response.responseBody?.items.item.count)
    }
    
    func test_fetchData호출시_관광지_서버오류로실패하는지() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 500)
        MockURLProtocol.setMockType(type: .trip)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(
            try await sut.fetchData(urlCase: .trip,
                                    tripKey: LocationDataModel(areaName: "",
                                                               sigunguName: "",
                                                               areaCode: 0,
                                                               sigunguCode: 0),
                                    type: TripNetworkResponse.self,
                                    page: 1)) { error in
                                        let error = error as! NetworkError
                                        XCTAssertEqual(error, NetworkError.serverError(code: 500))
                                    }
    }
    
    func test_fetchData호출시_날씨_서버오류로실패하는지() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 500)
        MockURLProtocol.setMockType(type: .weather)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(
            try await sut.fetchData(urlCase: .weather,
                                    weatherKey: ConvertedLocationModel(lat: 0,
                                                                       lng: 0,
                                                                       x: 0,
                                                                       y: 0),
                                    type: WeatherNetworkResponse.self,
                                    page: 1)
        ){ error in
            let error = error as! NetworkError
            XCTAssertEqual(error, NetworkError.serverError(code: 500))
        }
    }
    
    func test_fetchData호출시_관광지_URL이_올바르게구성이안된경우() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .trip)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(
            try await sut.fetchData(urlCase: .trip,
                                    type: TripNetworkResponse.self,
                                    page: 0)
        ) { error in
            let error = error as! NetworkError
            XCTAssertEqual(error, NetworkError.invalidURL)
        }
    }
    
    func test_fetchData호출시_날씨_URL이_올바르게구성이안된경우() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .weather)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(
            try await sut.fetchData(urlCase: .weather,
                                    type: TripNetworkResponse.self,
                                    page: 0)
        ) { error in
            let error = error as! NetworkError
            XCTAssertEqual(error, NetworkError.invalidURL)
        }
    }
    
    func test_fetchData호출시_날씨_데이터형식이_알맞지않은경우() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .wrong)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(
            try await sut.fetchData(urlCase: .weather,
                                    weatherKey: ConvertedLocationModel(lat: 0,
                                                                       lng: 0,
                                                                       x: 0,
                                                                       y: 0),
                                    type: TripNetworkResponse.self,
                                    page: 0)
        ) { error in
            let error = error as! NetworkError
            XCTAssertEqual(error, NetworkError.decodingError)
        }
    }
    
    func test_fetchData호출시_관광지_데이터형식이_알맞지않은경우() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .wrong)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(
            try await sut.fetchData(urlCase: .trip,
                                    tripKey: LocationDataModel(areaName: "",
                                                               sigunguName: "",
                                                               areaCode: 0,
                                                               sigunguCode: 0),
                                    type: TripNetworkResponse.self,
                                    page: 0)
        ) { error in
            let error = error as! NetworkError
            XCTAssertEqual(error, NetworkError.decodingError)
        }
    }
    
    
    override func tearDownWithError() throws {
        sut = nil
    }

}
extension XCTest {
    func XCTAssertThrowsError<T: Sendable>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
