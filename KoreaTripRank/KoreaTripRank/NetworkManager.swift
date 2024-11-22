//
//  NetworkManager.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/6/24.
//

import Foundation
import Alamofire

/*
 네트워크 매니저 하는일
 - url 구성
 - URLRequest 구성
 - 네트워크 통신
 - 디코딩
 */
enum NetworkError: Error {
    case decodingError
    case serverError(code: Int)
    case missingData
    case invalidURL
}

enum NetworkURLCase {
    case trip
    case weather
}

struct APIKEY {
    func getKey() -> String? {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) 
        else {
            return nil
        }
        return dict["APIKEY"] as? String
    }
}
// MARK: NetworkManager
class NetworkManager {
    let components: URLComponentable
    let decoder: DataDecodable
    static let shared = NetworkManager(components: URLComponentHandler(), decoder: DecodeHandler())
    
    private init(components: URLComponentable, decoder: DataDecodable) {
        self.components = components
        self.decoder = decoder
    }
    
    func fetchData<T: Decodable>(urlCase URLCase: NetworkURLCase,
                                 tripKey: LocationDataModel? = nil,
                                 weatherKey: ConvertedLocationModel? = nil,
                                 type: T.Type,
                                 page: Int) async throws -> T {
        var urlComponents = URLComponents()
        switch URLCase {
        case .trip:
            urlComponents = components.getURLComponents(for: .trip, page: page, tripKey: tripKey)
        case .weather:
            urlComponents = components.getURLComponents(for: .weather, page: page, weatherKey: weatherKey)
        }
        guard let url = urlComponents.url else {
            throw(NetworkError.invalidURL)
        }
        print(url)
        let request = AF.request(url)
        
        let response = await request.serializingDecodable(T.self).response
        guard (response.response)?.statusCode == 200 else {
            throw NetworkError.serverError(code: response.response?.statusCode ?? 0)
        }
        
        guard let data = response.value else {
            throw NetworkError.decodingError
        }
        return data
    }
}
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

// MARK: URLComponentable
protocol URLComponentable {
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents
}
extension URLComponentable {
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel? = nil, weatherKey: ConvertedLocationModel? = nil) -> URLComponents {
        return getURLComponents(for: type, page: page, tripKey: tripKey, weatherKey: weatherKey)
    }
}

class URLComponentHandler: URLComponentable {
    private let scheme = "https"
    private let host = "apis.data.go.kr"
    private let paths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    private let mobileOS: String = "iOS"
    private let mobileAppName: String = "KoreaTripRank"
    private let tripPaths: [String] = ["B551011", "TarRlteTarService", "areaBasedList"]
    private let weatherPaths: [String] = ["1360000","VilageFcstInfoService_2.0","getUltraSrtFcst"]
    
    private var currentDate: (baseDate: String, baseTime: String, baseDateYM: String) {
        let now = Date()
        let thirtyMinuteBefore = Calendar.current.date(byAdding: .minute, value: -30, to: now)!
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: now)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let baseDate = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "HHmm"
        let baseTime = dateFormatter.string(from: thirtyMinuteBefore)
        dateFormatter.dateFormat = "yyyyMM"
        let baseDateYM = dateFormatter.string(from: lastMonth)
        
        return (baseDate, baseTime, baseDateYM)
    }
    
    func getURLComponents(for type: NetworkURLCase, page: Int, tripKey: LocationDataModel?, weatherKey: ConvertedLocationModel?) -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        
        switch type {
        case .trip:
            guard let areaCd = tripKey?.areaCode,
                  let sigunguCd = tripKey?.sigunguCode else {
                return URLComponents()
            }
            components.path = "/" + tripPaths.joined(separator: "/")
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
                URLQueryItem(name: "numOfRows", value: "50"),
                URLQueryItem(name: "MobileOS", value: mobileOS),
                URLQueryItem(name: "MobileApp", value: mobileAppName),
                URLQueryItem(name: "baseYm", value: currentDate.baseDateYM),
                URLQueryItem(name: "areaCd", value: String(areaCd)),
                URLQueryItem(name: "signguCd", value: String(sigunguCd)),
                URLQueryItem(name: "_type", value: "json"),
                URLQueryItem(name: "pageNo", value: String(page))
            ]
        case .weather:
            guard let nx = weatherKey?.x,
                  let ny = weatherKey?.y else {
                return URLComponents()
            }
            components.path = "/" + weatherPaths.joined(separator: "/")
            components.percentEncodedQueryItems = [
                URLQueryItem(name: "serviceKey", value: APIKEY().getKey()),
                URLQueryItem(name: "numOfRows", value: "60"),
                URLQueryItem(name: "pageNo", value: String(page)),
                URLQueryItem(name: "dataType", value: "JSON"),
                URLQueryItem(name: "base_date", value: currentDate.baseDate),
                URLQueryItem(name: "base_time", value: currentDate.baseTime),
                URLQueryItem(name: "nx", value: String(nx)),
                URLQueryItem(name: "ny", value: String(ny))
            ]
        }
        return components
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
        let YO:Double = 136 // 기1준점 Y좌표(GRID)
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
