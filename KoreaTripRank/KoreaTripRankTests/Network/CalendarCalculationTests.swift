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
        
        // given
        dateFormatter.dateFormat = "yyyyMMdd"
        // when
        let currentDateString = dateFormatter.string(from: current)
        // then
        XCTAssertEqual(currentDateString, sut.getCurrentDateString(dateFormat: "yyyyMMdd"))
    }
    
    func test_getCurrentDateString호출시_문자길이가_맞는가() {
        // given
        let currentString = sut.getCurrentDateString(dateFormat: "yyyyMMdd")
        // when
        // then
        XCTAssertEqual(currentString.count, 8)
    }
    
    func test_getCurrentDateString호출시_문자형식이_맞는가() {
        // given
        dateFormatter.dateFormat = "yyyyMMdd"
        let currentString = sut.getCurrentDateString(dateFormat: "yyyyMMdd")
        // when
        let date = dateFormatter.date(from: currentString)
        // then
        XCTAssertNotNil(date, "getCurrentDateString: 문자열 형식이 맞지 않음")
    }

    func test_getAfterHourDateString호출시_한시간뒤날짜문자열이_나오는가() {
        // given
        dateFormatter.dateFormat = "HH"
        let afterHourDate = Calendar.current.date(byAdding: .hour, value: 1, to: current)
        let result = dateFormatter.string(from: afterHourDate!) + "00"
        // when
        let string = sut.getAfterHourDateString(dateFormat: "HH")
        // then
        XCTAssertEqual(result, string)
    }
    
    func test_getAfterHourDateString호출시_문자길이가_맞는가() {
        // given
        let afterHourDateString = sut.getAfterHourDateString(dateFormat: "HH")
        // when
        // then
        XCTAssertEqual(afterHourDateString.count, 4)
    }
    
    func test_getAfterHourDateString호출시_문자형식이_맞는가() {
        // given
        let afterHourDateString = sut.getAfterHourDateString(dateFormat: "HH")
        dateFormatter.dateFormat = "HHmm"
        // when
        let result = dateFormatter.date(from: afterHourDateString)
        // then
        XCTAssertNotNil(result, "getAfterHourDateString의 문자형식이 맞지 않음")
    }
    
    func test_getBeforeHalfHourDateString호출시_문자길이가_맞는가() {
        // given
        let length = 4
        let result = sut.getBeforeHalfHourDateString(dateFormat: "HHmm")
        // when
        // then
        XCTAssertEqual(result.count, length)
    }
    
    func test_getBeforeHalfHourDateString호출시_30분전의날짜문자열이_출력되는가() {
        // given
        dateFormatter.dateFormat = "HHmm"
        let beforeHalf = Calendar.current.date(byAdding: .minute, value: -30, to: Date())!
        let string = dateFormatter.string(from: beforeHalf)
        // when
        let result = sut.getBeforeHalfHourDateString(dateFormat: "HHmm")
        // then
        XCTAssertEqual(result, string)
    }
    
    func test_getBeforeHalfHourDateString호출시_날짜형식이_올바른가() {
        // given
        dateFormatter.dateFormat = "HHmm"
        let string = sut.getBeforeHalfHourDateString(dateFormat: "HHmm")
        // when
        let result = dateFormatter.date(from: string)
        // then
        XCTAssertNotNil(result)
    }
    
    func test_getBeforeMonthDateString호출시_문자길이가_맞는가() {
        // given
        let length = 6
        let string = sut.getBeforeMonthDateString(dateFormat: "yyyyMM")
        // when
        // then
        XCTAssertEqual(string.count, length)
    }
    
    func test_getBeforeMonthDateString호출시_지난달의날짜문자열이_출력되는가() {
        // given
        dateFormatter.dateFormat = "yyyyMM"
        let beforeMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let string = dateFormatter.string(from: beforeMonthDate)
        // when
        let result = sut.getBeforeMonthDateString(dateFormat: "yyyyMM")
        // then
        XCTAssertEqual(string, result)
    }
    
    func test_getBeforeMonthDateString호출시_날짜형식이_올바른가() {
        // given
        dateFormatter.dateFormat = "yyyyMM"
        let string = sut.getBeforeMonthDateString(dateFormat: "yyyyMM")
        // when
        let date = dateFormatter.date(from: string)
        // then
        XCTAssertNotNil(date)
    }
}
