//
//  ConvertedLocationDataModelTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 12/2/24.
//

import XCTest
@testable import KoreaTripRank

final class ConvertedLocationModelTests: XCTestCase {

    var sut: ConvertedLocationModel!
    override func setUpWithError() throws {
        sut = ConvertedLocationModel(lat: 0, lng: 0)
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_생성확인() {
        // given
        let data = ConvertedLocationModel(lat: 0, lng: 0)
        // when
        // then
        XCTAssertNotNil(data)
    }
    
    func test_xy인자가Nil인경우() {
        // given
        let data = ConvertedLocationModel(lat: 0, lng: 0)
        // when
        // then
        XCTAssertNotNil(data)
    }
    
    func test_인자가_음수인경우() {
        // given
        let data = ConvertedLocationModel(lat: -50, lng: -50)
        // when
        // then
        XCTAssertNotNil(data)
    }
    
    func test_convertGRID_GPS호출시_GRID로정상적으로값이변환되는지() {
        // given
        sut.lat = 50
        sut.lng = 50
        // when
        sut.convertGRID_GPS(mode: 0, lat_X: sut.lat, lng_Y: sut.lng)
        // then
        XCTAssertNotNil(sut.x)
        XCTAssertNotNil(sut.y)
    }
    func test_convertGRID_GPS호출시_GPS로정상적으로값이변환되는지() {
        // given
        sut.lat = 50
        sut.lng = 50
        // when
        sut.convertGRID_GPS(mode: 1, lat_X: sut.lat, lng_Y: sut.lng)
        // then
        XCTAssertNotNil(sut.x)
        XCTAssertNotNil(sut.y)
    }

}
