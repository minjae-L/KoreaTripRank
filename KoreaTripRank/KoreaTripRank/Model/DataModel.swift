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


// MARK: - 위도 경도 변환
// 위도 경도 변환 데이터 모델
struct ConvertedLocationModel {
    public var lat: Double
    public var lng: Double
    public var x: Int?
    public var y: Int?
    
    init(lat: Double, lng: Double, x: Int? = nil, y: Int? = nil) {
        self.lat = lat
        self.lng = lng
        self.x = x
        self.y = y
    }
    
    mutating func convertGRID_GPS(mode: Int, lat_X: Double, lng_Y: Double) {
        let RE = 6371.00877 // 지구 반경(km)
        let GRID = 5.0 // 격자 간격(km)
        let SLAT1 = 30.0 // 투영 위도1(degree)
        let SLAT2 = 60.0 // 투영 위도2(degree)
        let OLON = 126.0 // 기준점 경도(degree)
        let OLAT = 38.0 // 기준점 위도(degree)
        let XO:Double = 43 // 기준점 X좌표(GRID)
        let YO:Double = 136 // 기준점 Y좌표(GRID)
        let DEGRAD = Double.pi / 180.0
        let RADDEG = 180.0 / Double.pi
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        let TO_GRID = 0
        let TO_GPS = 1
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        var rs = ConvertedLocationModel(lat: 0, lng: 0, x: 0, y: 0)
        
        if mode == TO_GRID {
            rs.lat = lat_X
            rs.lng = lng_Y
            var ra = tan(Double.pi * 0.25 + (lat_X) * DEGRAD * 0.5)
            ra = re * sf / pow(ra, sn)
            var theta = lng_Y * DEGRAD - olon
            if theta > Double.pi {
                theta -= 2.0 * Double.pi
            }
            if theta < -Double.pi {
                theta += 2.0 * Double.pi
            }
            
            theta *= sn
            rs.x = Int(floor(ra * sin(theta) + XO + 0.5))
            rs.y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        }
        else {
            rs.x = Int(lat_X)
            rs.y = Int(lng_Y)
            let xn = lat_X - XO
            let yn = ro - lng_Y + YO
            var ra = sqrt(xn * xn + yn * yn)
            if (sn < 0.0) {
                ra = -ra
            }
            var alat = pow((re * sf / ra), (1.0 / sn))
            alat = 2.0 * atan(alat) - Double.pi * 0.5
            
            var theta = 0.0
            if (abs(xn) <= 0.0) {
                theta = 0.0
            }
            else {
                if (abs(yn) <= 0.0) {
                    theta = Double.pi * 0.5
                    if (xn < 0.0) {
                        theta = -theta
                    }
                }
                else {
                    theta = atan2(xn, yn)
                }
            }
            let alon = theta / sn + olon
            rs.lat = alat * RADDEG
            rs.lng = alon * RADDEG
        }
        self.lat = rs.lat
        self.lng = rs.lng
        self.x = rs.x
        self.y = rs.y
    }
}
