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
    var weatherModel: [WeatherDataModel]?
    var isExpanded: Bool = false

    enum CodingKeys: String, CodingKey {
        case areaName = "tAtsNm"
        case relatedAreaName = "rlteTatsNm"
        case relatedAreaAddress = "rlteBsicAdres"
        case relatedLargeCategoryName = "rlteCtgryLclsNm"
        case relatedMediumCategoryName = "rlteCtgryMclsNm"
        case relatedSmallCategoryName = "rlteCtgrySclsNm"
        case rankNum = "rlteRank"
        case weatherModel = "weather"
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
/*
PTY: 강수형태
 0: 없음, 1: 비, 2: 비/눈, 5: 빗방울, 6: 빗방울,눈날림, 7: 눈날림
 rn1 강수량
 강수없음
 sky 하늘상태
 1: 맑음, 3: 구름많음, 4: 흐림
 t1h 기온
 
 WSD: 풍속
 */
struct WeatherDataModel: Decodable {
    let baseDate: String
    let fcstTime: String
    let nx: String
    let ny: String
    let temp: String
    let rainAmount: String
    let rainState: String
    let skyState: String
    let wind: String
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

