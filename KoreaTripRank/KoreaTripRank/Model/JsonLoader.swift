//
//  AreaDatabase.swift
//  KoreaTripRank
//
//  Created by 이민재 on 12/3/24.
//

import Foundation

// MARK: - AreaDatabase
enum JsonLoadError: Error {
    case dataConvertError
    case invalidURL
    case decodingError
    
    func printDescription() {
        switch self {
        case .dataConvertError:
            print("dataConvertError")
        case .invalidURL:
            print("invalidURL")
        case .decodingError:
            print("decodingError")
        }
    }
}

class JsonLoader {
    
    enum FileName {
        case trip
        case weather
        case areaCode
        
        var name: String {
            switch self {
            case .trip: return "MockTripData"
            case .weather: return "MockWeatherData"
            case .areaCode: return "AreaCode"
            }
        }
        var `extension`: String {
            return "json"
        }
    }
    
    let fileExtension = "json"
    
    private func dataThrow(fileName: FileName) throws -> Data? {
        guard let url = Bundle.main.url(forResource: fileName.name, withExtension: fileName.extension) else {
            throw(JsonLoadError.invalidURL)
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            throw(JsonLoadError.dataConvertError)
        }
    }
    
    private func loadThrow<T: Decodable>(type: T.Type, fileName: FileName) throws -> T {
        do {
            guard let data = try dataThrow(fileName: fileName) else {
                throw(JsonLoadError.dataConvertError)
            }
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw(JsonLoadError.decodingError)
        }
    }
}

extension JsonLoader {
    func data(fileName: FileName) -> Data? {
        do {
            return try dataThrow(fileName: fileName)
        } catch {
            return nil
        }
    }
    
    func load<T: Decodable>(type: T.Type, fileName: FileName) -> T? {
        do {
            return try loadThrow(type: type, fileName: fileName)
        } catch {
            return nil
        }
    }
}
