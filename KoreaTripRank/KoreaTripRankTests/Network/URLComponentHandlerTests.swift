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
        let urlKeys = URLKeys()
        sut = URLComponentHandler(urlKeys: urlKeys)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_생성확인() {
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.urlKeys)
    }
    
    func test_getURLComponents호출시_Key값이모두Nil인경우_빈Components리턴() {
        // when
        let result = sut.getURLComponents(page: 0, tripKey: nil, weatherKey: nil)
        // then
        XCTAssertNil(result.queryItems)
    }
    
    func test_getURLComponents호출시_Key값이모두전달되면_빈Components리턴() {
        // given
        let dummyWeatherKey = ConvertedLocationModel(lat: 0,
                                                     lng: 0,
                                                     x: 0,
                                                     y: 0)
        let dummyTripKey = LocationDataModel(areaName: "",
                                             sigunguName: "",
                                             areaCode: 0,
                                             sigunguCode: 0)
        // when
        let result = sut.getURLComponents(page: 0, tripKey: dummyTripKey, weatherKey: dummyWeatherKey)
        // then
        XCTAssertNil(result.queryItems)
    }
    
    func test_getURLComponents호출시_weatherKey의xy가nil인경우_빈배열리턴() {
        // given
        let dummyWrongWeatherKey = ConvertedLocationModel(lat: 0, lng: 0)
        
        // when
        let result = sut.getURLComponents(page: 0, tripKey: nil, weatherKey: dummyWrongWeatherKey)
        // then
        XCTAssertEqual(result.queryItems, [])
    }
    
    func test_getURLComponents호출시_Key전달시_정상적인값리턴() {
        // given
        let dummyWeatherKey = ConvertedLocationModel(lat: 0,
                                                     lng: 0,
                                                     x: 0,
                                                     y: 0)
        let dummyTripKey = LocationDataModel(areaName: "",
                                             sigunguName: "",
                                             areaCode: 0,
                                             sigunguCode: 0)
        // when
        let weatherResult = sut.getURLComponents(page: 0, tripKey: nil, weatherKey: dummyWeatherKey)
        let tripResult = sut.getURLComponents(page: 0, tripKey: dummyTripKey, weatherKey: nil)
        // then
        XCTAssertNotNil(weatherResult.queryItems)
        XCTAssertNotNil(tripResult.queryItems)
        XCTAssertEqual(weatherResult.queryItems?.count, 8)
        XCTAssertEqual(tripResult.queryItems?.count, 9)
    }
}
