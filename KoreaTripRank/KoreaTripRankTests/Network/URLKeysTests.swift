//
//  URLKeysTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 11/30/24.
//

import XCTest
@testable import KoreaTripRank

final class URLKeysTests: XCTestCase {
    var sut: URLKeys!
    
    override func setUpWithError() throws {
        let mockCalendarCal = MockCalendarCalculation()
        sut = URLKeys(calendarCalculation: mockCalendarCal)
    }

    func test_qetQueryItems호출시_weatherKey가nil인경우() {
        // given
        let dummyWeatherKey: ConvertedLocationModel? = nil
        // when
        let result = sut.getQueryItems(page: 1, weatherKey: dummyWeatherKey)
        // then
        XCTAssertEqual(result.count, 0)
    }
    
    func test_getQueryItems호출시_weatherKey의xy값이Nil인경우() {
        // given
        let dummyWeatherKey = ConvertedLocationModel(lat: 0, lng: 0)
        // when
        let result = sut.getQueryItems(page: 1, weatherKey: dummyWeatherKey)
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_getQueryItems호출시_weatherKey의xy값이Nil이아닌경우() {
        // given
        let dummyWeatherKey = ConvertedLocationModel(lat: 0, lng: 0, x: 0, y: 0)
        // when
        let result = sut.getQueryItems(page: 1, weatherKey: dummyWeatherKey)
        // then
        XCTAssertNotEqual(result, [])
    }
    
    func test_getQueryItems호출시_tripKey가nil인경우() {
        // given
        // when
        let result = sut.getQueryItems(page: 1)
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_getQueryItems호출시_tripKey가_정상적으로전달한경우() {
        // given
        let dummyTripKey = LocationDataModel(areaName: "dummy", sigunguName: "dummy", areaCode: 30, sigunguCode: 30)
        // when
        let result = sut.getQueryItems(page: 1, tripKey: dummyTripKey)
        // given
        XCTAssertNotEqual(result, [])
    }
    
    func test_getQueryItems호출시_QueryItem의배열크기가정상적으로리턴되는지() {
        // given
        let dummyTripKey = LocationDataModel(areaName: "dummy", sigunguName: "dummy", areaCode: 30, sigunguCode: 30)
        let dummyWeatherKey = ConvertedLocationModel(lat: 0, lng: 0, x: 0, y: 0)
        // when
        let tripResult = sut.getQueryItems(page: 1, tripKey: dummyTripKey)
        let weatherResult = sut.getQueryItems(page: 1, weatherKey: dummyWeatherKey)
        // then
        XCTAssertEqual(tripResult.count, 9)
        XCTAssertEqual(weatherResult.count, 8)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }

}
