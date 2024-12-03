//
//  AreaDatabase.swift
//  KoreaTripRank
//
//  Created by 이민재 on 12/3/24.
//

import Foundation

// MARK: - AreaDatabase
enum AreaDatabaseLoadError: Error {
    case fileNotExist
    case invalidFileName
    case invalidFileExtension
    case invalidURL
    case dataConvertError
    case decodingError
}

struct AreaDatabase {
    var data: [LocationDataModel] = []
    var jsonData: Data?
    var fileName = "AreaCode"
    var fileExtension = "json"
    var fileURL: URL?
    
    
    mutating func initDatabase() {
        do {
            try loadFileURL()
            try convertData(url: self.fileURL)
            try decode(data: self.jsonData)
        } catch AreaDatabaseLoadError.invalidURL {
            print("AreaDatabaseLoadError:: invalidURL")
        } catch AreaDatabaseLoadError.dataConvertError {
            print("AreaDatabaseLoadError:: dataConvertError")
        } catch AreaDatabaseLoadError.invalidFileName {
            print("AreaDatabaseLoadError:: invalidFileName")
        } catch AreaDatabaseLoadError.invalidFileExtension {
            print("AreaDatabaseLoadError:: invalidFileExtension")
        } catch AreaDatabaseLoadError.fileNotExist {
            print("AreaDatabaseLoadError:: fileNotExist")
        } catch AreaDatabaseLoadError.decodingError {
            print("AreaDatabaseLoadError:: decodingError")
        } catch {
            print("AreaDatabaseLoadError:: unExpected Error")
        }
    }
    // 데이터 불러오기
    mutating func loadFileURL() throws {
        // 파일 위치
        guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            if fileName != "AreaCode" { throw(AreaDatabaseLoadError.invalidFileName)
            } else if fileExtension != "json" { throw(AreaDatabaseLoadError.invalidFileExtension)
            } else {
                throw(AreaDatabaseLoadError.fileNotExist)
            }
        }
        self.fileURL = fileLocation
    }
    
    mutating func convertData(url: URL?) throws {
        guard let url = url else {
            throw(AreaDatabaseLoadError.invalidURL)
        }
        // 해당 파일을 Data로 변환
        do {
            let data = try Data(contentsOf: url)
            self.jsonData = data
        } catch {
            throw(AreaDatabaseLoadError.dataConvertError)
        }
    }
    
    
    mutating func decode(data: Data?) throws {
        guard let data = self.jsonData else {
            throw(AreaDatabaseLoadError.dataConvertError)
        }
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(LocationModel.self, from: data)
            self.data = decoded.data
        } catch {
            print(String(describing: error))
            throw(AreaDatabaseLoadError.decodingError)
        }
    }
}
