//
//  APIKEY.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/28/24.
//

import Foundation

enum APIKEY {
    static let key: String? = {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url)
        else {
            return nil
        }
        return dict["APIKEY"] as? String
    }()
}
