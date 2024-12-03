//
//  AreaDatabaseTests.swift
//  KoreaTripRankTests
//
//  Created by 이민재 on 12/2/24.
//

import XCTest

final class AreaDatabaseTests: XCTestCase {
    var sut: AreaDatabase!
    override func setUpWithError() throws {
        sut = AreaDatabase()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_loadFileURL호출시_생성확인() {
        // given
        let areaDatabase = AreaDatabase()
        
        // when
        // then
        XCTAssertNotNil(areaDatabase)
    }
    
    func test_loadFileURL호출시_올바른파일명과확장자로_접근했는지() {
        // given
        sut.fileName = "AreaCode"
        sut.fileExtension = "json"
        // when
        // then
        XCTAssertNoThrow(try sut.loadFileURL())
    }
    
    func test_loadFileURL호출시_올바르지않은파일명으로_접근했는지() {
        // given
        sut.fileName = "?@>#O"
        sut.fileExtension = "json"
        // when
        // then
        XCTAssertThrowsError(try sut.loadFileURL()) { error in
            XCTAssertEqual(error as? AreaDatabaseLoadError, AreaDatabaseLoadError.invalidFileName)
        }
    }
    
    func test_loadFileURL호출시_올바르지않은확장자로_접근했는지() {
        // given
        sut.fileName = "AreaCode"
        sut.fileExtension = "$%(#@"
        // when
        // then
        XCTAssertThrowsError(try sut.loadFileURL()) { error in
            XCTAssertEqual(error as? AreaDatabaseLoadError,
                           AreaDatabaseLoadError.invalidFileExtension)
        }
    }
    
    func test_convertData호출시_데이터변환이성공인지() {
        // given
        sut.fileName = "AreaCode"
        sut.fileExtension = "json"
        // when
        // given
        XCTAssertNoThrow(try sut.loadFileURL())
        XCTAssertNoThrow(try sut.convertData(url: sut.fileURL))
    }
    
    func test_convertData호출시_올바르지않은url입력시() {
        // given
        // when
        sut.fileURL = URL(string: "")
        // then
        XCTAssertThrowsError(try sut.convertData(url: sut.fileURL)) { error in
            XCTAssertEqual(error as? AreaDatabaseLoadError,
                           AreaDatabaseLoadError.invalidURL)
        }
    }
    
    func test_decode호출시_성공적으로디코딩이되었는지() {
        // given
        sut.fileName = "AreaCode"
        sut.fileExtension = "json"
        // when
        
        // then
        XCTAssertNoThrow(try sut.loadFileURL())
        XCTAssertNoThrow(try sut.convertData(url: sut.fileURL!))
        XCTAssertNoThrow(try sut.decode(data: sut.jsonData))
    }
    
    func test_decode호출시_URL이올바르지않은지() {
        // given
        sut.fileName = "AreaCode"
        sut.fileExtension = "json"
        // when
        sut.jsonData = nil
        // then
        XCTAssertThrowsError(try sut.decode(data: sut.jsonData)) { error in
            XCTAssertEqual(error as? AreaDatabaseLoadError,
                           AreaDatabaseLoadError.dataConvertError)}
    }
    
    func test_initDatabase호출시_정상적으로데이터가생성되었는지() {
        // given
        sut.fileName = "AreaCode"
        sut.fileExtension = "json"
        // when
        sut.initDatabase()
        // then
        XCTAssertNotNil(sut.jsonData)
        XCTAssertNotNil(sut.fileURL)
        XCTAssertNotEqual(sut.data.count, 0)
    }
}
