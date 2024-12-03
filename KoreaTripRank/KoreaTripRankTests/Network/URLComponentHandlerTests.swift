//
//  URLComponentHandlerTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 11/28/24.
//

import XCTest
@testable import KoreaTripRank
final class URLComponentHandlerTests: XCTestCase {
    private var sut: URLComponentHandler!
    override func setUpWithError() throws {
        let mockCalendarCalculation = MockCalendarCalculation()
        let mockAPIKey = MockAPIKEY()
        let urlKeys = URLKeys(calendarCalculation: mockCalendarCalculation,
                              APIKEY: mockAPIKey)
        sut = URLComponentHandler(urlKeys: urlKeys)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_getURLComponents호출시_베이스URL을가져오는지() {
        // given
        let weatherType = NetworkURLCase.weather
        let tripType = NetworkURLCase.trip
        // given
        let weatherResult = sut.getURLComponents(for: weatherType, page: 1)
        let tripResult = sut.getURLComponents(for: tripType, page: 1)
        //then
        XCTAssertNotNil(weatherResult.url)
        XCTAssertNotNil(tripResult.url)
    }
    
    func test_getURLComponents호출시_QueryItems가구성되는지() {
        // given
        let weatherType = NetworkURLCase.weather
        let weatherKey = ConvertedLocationModel(lat: 0, lng: 0, x: 0, y: 0)
        let tripType = NetworkURLCase.trip
        let tripKey = LocationDataModel(areaName: "", sigunguName: "", areaCode: 0, sigunguCode: 0)
        // given
        let weatherResult = sut.getURLComponents(for: weatherType, page: 1, weatherKey: weatherKey)
        let tripResult = sut.getURLComponents(for: tripType, page: 1, tripKey: tripKey)
        //then
        XCTAssertEqual(tripResult.queryItems!.count , 9)
        XCTAssertEqual(weatherResult.queryItems!.count, 8)
    }
}
