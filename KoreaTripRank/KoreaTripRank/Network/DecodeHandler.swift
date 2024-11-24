//
//  DecodeHandler.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation

// MARK: DataDecodable
protocol DataDecodable {
    func decode<T: Decodable>(type: T.Type, data: Data?) -> T?
}

class DecodeHandler: DataDecodable {
    func decode<T: Decodable>(type: T.Type, data: Data?) -> T? {
        guard let data = data else { return nil }
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("Success Decoded")
            return decoded
        } catch {
            print("decoded Error")
            return nil
        }
    }
}
