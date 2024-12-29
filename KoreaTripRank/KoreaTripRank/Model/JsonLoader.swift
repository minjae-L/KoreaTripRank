//
//  AreaDatabase.swift
//  KoreaTripRank
//
//  Created by 이민재 on 12/3/24.
//

import Foundation

// MARK: - AreaDatabase
enum JsonLoadError: Error, CustomDebugStringConvertible {
    case dataConvertError
    case invalidURL
    case decodingError
    
    var debugDescription: String {
        switch self {
        case .dataConvertError:
            return "dataConvertError"
        case .invalidURL:
            return "invalidURL"
        case .decodingError:
            return "decodingError"
        }
    }
}

final class JsonLoader {
    
    private let fileExtension = "json"
    
    private func dataThrow(fileName: String) throws -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print(JsonLoadError.invalidURL.debugDescription)
            throw(JsonLoadError.invalidURL)
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print(JsonLoadError.dataConvertError.debugDescription)
            throw(JsonLoadError.dataConvertError)
        }
    }
    
    private func loadThrow<T: Decodable>(type: T.Type, fileName: String) throws -> T {
        do {
            guard let data = try dataThrow(fileName: fileName) else {
                print(JsonLoadError.dataConvertError.debugDescription)
                throw(JsonLoadError.dataConvertError)
            }
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print(JsonLoadError.decodingError.debugDescription)
            throw(JsonLoadError.decodingError)
        }
    }
}

extension JsonLoader {
    func data(fileName: String) -> Data? {
        do {
            return try dataThrow(fileName: fileName)
        } catch {
            return nil
        }
    }
    
    func load<T: Decodable>(type: T.Type, fileName: String) -> T? {
        do {
            return try loadThrow(type: type, fileName: fileName)
        } catch {
            return nil
        }
    }
}
