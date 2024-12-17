//
//  APIKEYTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 11/27/24.
//

import XCTest
@testable import KoreaTripRank

final class APIKEYTests: XCTestCase {
    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }
    
    func test_APIKEY호출시_URL문자열이_정상적으로_구성되는가() {
        // given
        let result = APIKEY.key
        // when
        // then
        XCTAssertNotNil(result, "URL 구성 오류 (URL = nil)")
    }
    
    func test_Info파일이존재하는지() {
        // when
        let url = Bundle.main.url(forResource: "Info", withExtension: "plist")
        // then
        XCTAssertNotNil(url, "Info.plist 파일이 존재하지 않음")
    }
}
