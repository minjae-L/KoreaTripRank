//
//  DataModel.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import Foundation

struct LocationModel: Decodable {
    let data: [LocationDataModel]
}
struct LocationDataModel: Decodable {
    let areaName: String
    let sigunguName: String
    let areaCode: Int
    let sigunguCode: Int
    
    enum CodingKeys: String, CodingKey {
        case areaName = "areaNm"
        case sigunguName = "sigunguNm"
        case areaCode = "areaCd"
        case sigunguCode = "signguCd"
    }
}
class AreaDatabase {
    var data: [LocationDataModel] = []
    var jsonData: Data?
    
    // 데이터 불러오기
    func load() -> Data? {
        // 파일이름
        let fileName = "AreaCode"
        // 파일 확장자
        let fileType = "json"
        // 파일 위치
        guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: fileType) else { return nil }
        
        // 해당 파일을 Data로 변환
        do {
            let data = try Data(contentsOf: fileLocation)
            return data
        } catch {
            return nil
        }
    }
    init() {
        self.jsonData = load()
        self.data = decode(data: jsonData)
    }
    func decode(data: Data?) -> [LocationDataModel] {
        guard let data = data else { return [] }
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(LocationModel.self, from: data)
            return decoded.data
        } catch {
            print(String(describing: error))
            return []
        }
    }
}


