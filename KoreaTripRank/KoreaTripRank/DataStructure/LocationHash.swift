//
//  LocationHash.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation

// 위치정보가 저장된 해쉬 자료구조 정의
final class LocationHash {
    private var hashTable: [[(key: String, value: ConvertedLocationModel)]]
    private let tableSize: Int
    static let shared = LocationHash(hashTable: [[]], tableSize: 1000)
    
    init(hashTable: [[(key: String, value: String)]], tableSize: Int) {
        self.tableSize = tableSize
        self.hashTable = Array(repeating: [], count: tableSize)
    }
    
    private func getHashKey(key: String) -> Int {
        return abs(key.hashValue) % tableSize
    }
    
    func put(element: (key: String, value: ConvertedLocationModel)) {
        let hashKey = getHashKey(key: element.key)
        for i in 0..<hashTable[hashKey].count {
            if hashTable[hashKey][i].key == element.key {
                hashTable[hashKey][i].value = element.value
            }
        }
        hashTable[hashKey].append(element)
    }
    
    func get(key: String) -> ConvertedLocationModel? {
        let hashKey = getHashKey(key: key)
        
        for i in 0..<hashTable[hashKey].count {
            if hashTable[hashKey][i].key == key {
                return hashTable[hashKey][i].value
            }
        }
        return nil
    }
}
