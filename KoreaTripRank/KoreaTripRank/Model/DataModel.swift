//
//  DataModel.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import Foundation

// MARK: - HTTP 통신 데이터 모델 <관광지>
struct TripNetworkResponse: Decodable {
    let response: TripResponse
}
struct TripResponse: Decodable {
    let responseHeader: TripResponseHeader
    let responseBody: TripResponseBody

    enum CodingKeys: String, CodingKey {
        case responseHeader = "header"
        case responseBody = "body"
    }
}
struct TripResponseBody: Decodable {
    let items: TripItems
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}
struct TripItems: Decodable {
    let item: [TripItem]
}
struct TripItem: Decodable {
    let areaName: String
    let relatedAreaName: String
    let relatedAreaAddress: String
    let relatedLargeCategoryName: String
    let relatedMediumCategoryName: String
    let relatedSmallCategoryName: String
    let rankNum: String
    let nx: String?
    let ny: String?

    enum CodingKeys: String, CodingKey {
        case areaName = "tAtsNm"
        case relatedAreaName = "rlteTatsNm"
        case relatedAreaAddress = "rlteBsicAdres"
        case relatedLargeCategoryName = "rlteCtgryLclsNm"
        case relatedMediumCategoryName = "rlteCtgryMclsNm"
        case relatedSmallCategoryName = "rlteCtgrySclsNm"
        case rankNum = "rlteRank"
        case nx = "nx"
        case ny = "ny"
    }
}
struct TripResponseHeader: Decodable {
    let resultCode: String
    let resultMessage: String

    enum CodingKeys : String, CodingKey {
        case resultCode
        case resultMessage = "resultMsg"
    }
}
// MARK: - HTTP 통신 데이터 모델 <날씨>
struct WeatherNetworkResponse: Decodable {
    let response: WeatherResponse
}

struct WeatherResponse: Decodable {
    let responseHeader: WeatherResponseHeader
    let responseBody: WeatherResponseBody?
    
    enum CodingKeys: String, CodingKey {
        case responseHeader = "header"
        case responseBody = "body"
    }
}
struct WeatherResponseHeader: Decodable {
    let resultCode: String
}

struct WeatherResponseBody: Decodable {
    let items: WeatherItems
}
struct WeatherItems: Decodable {
    let item: [WeatherItem]
}
struct WeatherItem: Decodable {
    let baseDate: String
    let baseTime: String
    let category: String
    let fcstTime: String
    let fcstValue: String
}
// MARK: - 지역 모델
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


