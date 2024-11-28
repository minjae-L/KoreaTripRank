//
//  CalendarCalculationTest.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 11/27/24.
//

import XCTest
@testable import KoreaTripRank
final class CalendarCalculationTests: XCTestCase {
    var sut: CalendarCalculation!
    var dateFormatter: DateFormatter!
    var current: Date!
    override func setUpWithError() throws {
        sut = CalendarCalculation()
        current = Date()
        dateFormatter = DateFormatter()
    }
    override func tearDownWithError() throws {
        sut = nil
        current = nil
        dateFormatter = nil
    }
    func test_getCurrentDateString호출시_현재날짜가_나오는가() {
        
        //given
        dateFormatter.dateFormat = "yyyyMMdd"
        //when
        let currentDateString = dateFormatter.string(from: current)
        //then
        XCTAssertEqual(currentDateString, sut.getCurrentDateString())
    }
    func test_getCurrentDateString호출시_문자길이가_맞는가() {
        // given
        let currentString = sut.getCurrentDateString()
        // when
        // then
        XCTAssertEqual(currentString.count, 8)
    }
    func test_getCurrentDateString호출시_문자형식이_맞는가() {
        // given
        dateFormatter.dateFormat = "yyyyMMdd"
        let currentString = sut.getCurrentDateString()
        // when
        let date = dateFormatter.date(from: currentString)
        // then
        XCTAssertNotNil(date, "getCurrentDateString: 문자열 형식이 맞지 않음")
    }

    func test_getAfterHourDateString호출시_의도한값이_나오는가() {
        // given
        dateFormatter.dateFormat = "HH"
        let afterHourDate = Calendar.current.date(byAdding: .hour, value: 1, to: current)
        let result = dateFormatter.string(from: afterHourDate!) + "00"
        // when
        let string = sut.getAfterHourDateString()
        // then
        XCTAssertEqual(result, string)
    }
    
    func test_getAfterHourDateString호출시_문자길이가_맞는가() {
        // given
        let afterHourDateString = sut.getAfterHourDateString()
        // when
        // then
        XCTAssertEqual(afterHourDateString.count, 4)
    }
    
    func test_getAfterHourDateString호출시_문자형식이_맞는가() {
        // given
        let afterHourDateString = sut.getAfterHourDateString()
        dateFormatter.dateFormat = "HHmm"
        // when
        let result = dateFormatter.date(from: afterHourDateString)
        // then
        XCTAssertNotNil(result, "getAfterHourDateString의 문자형식이 맞지 않음")
    }
}
