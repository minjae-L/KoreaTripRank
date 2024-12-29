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
        sut = URLKeys()
    }
    
    func test_getQueryItems호출시_두개의key모두nil인경우_빈배열리턴() {
        // when
        let result = sut.getQueryItems(page: 0)
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_getQueryItems호출시_두개의Key모두입력받는경우_빈배열리턴() {
        // when
        let result = sut.getQueryItems(page: 0,
                                       weatherKey: ConvertedLocationModel(lat: 0,
                                                                          lng: 0),
                                       tripKey: LocationDataModel(areaName: "",
                                                                  sigunguName: "",
                                                                  areaCode: 0,
                                                                  sigunguCode: 0))
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_getQueryItems호출시_weatherKey의xy값이_nil이면_빈배열리턴() {
        // given
        let dummyWrongWeatherKey = ConvertedLocationModel(lat: 0, lng: 0)
        // when
        let result = sut.getQueryItems(page: 0, weatherKey: dummyWrongWeatherKey)
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_getQueryItems호출시_tripKey가Nil인경우_빈배열리턴() {
        // when
        let result = sut.getQueryItems(page: 0, tripKey: nil)
        // then
        XCTAssertEqual(result, [])
    }
    
    func test_getQueryItems호출시_Key값이전달되면_정상적으로리턴() {
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
        let weatherResult = sut.getQueryItems(page: 0, weatherKey: dummyWeatherKey)
        let tripResult = sut.getQueryItems(page: 0, tripKey: dummyTripKey)
        // then
        XCTAssertEqual(weatherResult.count, 8)
        XCTAssertEqual(tripResult.count, 9)
        
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }

}
