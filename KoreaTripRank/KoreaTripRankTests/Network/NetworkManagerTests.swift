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
    
    func test_fetchData호출시_관광지데이터가성공적으로불러오는지() async throws {
        // given
        let expectation = expectation(description: "비동기 네트워크 작업")
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .trip)
        
        var session = URLSessionConfiguration.af.default
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
        expectation.fulfill()
        // then
        XCTAssertNoThrow(result)
        XCTAssertEqual(result.response.responseBody.items.item.count, expectationResult?.response.responseBody.items.item.count)
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func test_fetchData호출시_관광지데이터서버오류로실패하는지() async throws {
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 500)
        MockURLProtocol.setMockType(type: .trip)
        
        let session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]
        
        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        // then
        await XCTAssertThrowsError(try await sut.fetchData(urlCase: .trip,
                                                     tripKey: LocationDataModel(areaName: "",
                                                                                sigunguName: "",
                                                                                areaCode: 0,
                                                                                sigunguCode: 0),
                                                     type: LocationDataModel.self,
                                                           page: 0)) { error in
            XCTAssertEqual(error as! NetworkError, NetworkError.serverError(code: 500))
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
