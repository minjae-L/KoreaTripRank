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
        let expectation = expectation(description: "비동기 네트워크 작업")
        // given
        MockURLProtocol.setMockResponseWithStatusCode(code: 200)
        MockURLProtocol.setMockType(type: .trip)
        print(MockURLProtocol.self)
        var session = URLSessionConfiguration.af.default
        session.protocolClasses = [MockURLProtocol.self]

        let mockSession = Session(configuration: session)
        sut = NetworkManager(session: mockSession)
        // when
        let expectationResult = JsonLoader().load(type: TripNetworkResponse.self, fileName: "MockTripData")
        let result = try await sut.fetchData(urlCase: .trip, tripKey: LocationDataModel(areaName: "", sigunguName: "", areaCode: 0, sigunguCode: 0), type: TripNetworkResponse.self, page: 1)
        expectation.fulfill()
        // then
        await waitForExpectations(timeout: 3)
        XCTAssertNoThrow(result)
        XCTAssertEqual(result.response.responseBody.items.item.count, expectationResult?.response.responseBody.items.item.count)
    }
    override func tearDownWithError() throws {
        sut = nil
    }

}
