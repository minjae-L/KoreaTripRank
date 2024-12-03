//
//  NetworkServiceKeyTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 11/27/24.
//

import XCTest
@testable import KoreaTripRank

final class NetworkServiceKeyTests: XCTestCase {
    var sut: APIKEY!
    override func setUpWithError() throws {
        sut = APIKEY()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_LoadAPIKEY호출시_URL이_정상적으로_구성되는가() {
        // given
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")
        // when
        // then
        XCTAssertNotNil(url, "URL 구성 오류 (URL = nil)")
    }
    
    func test_LoadAPIKEY호출시_URL딕셔너리를_성공적으로_불러오는가() {
        // given
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")
        // when
        let dict = NSDictionary(contentsOf: url!)
        // then
        XCTAssertNotNil(dict)
    }
    
    func test_LoadAPIKEY호출시_딕셔너리안에_APIKEY가_존재하는가() {
        // given
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: url!)
        // when
        let result = dict?["APIKEY"] as? String
        // then
        XCTAssertNotNil(result)
    }
    
    func test_LoadAPIKEY호출시_결과가_성공적으로_불러오는가() {
        // given
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")
        let dict = NSDictionary(contentsOf: url!)
        let result = dict?["APIKEY"] as? String
        // when
        let key = sut.getKey()
        // then
        XCTAssertEqual(key, result)
    }
}
