//
//  SearchViewModel.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import Foundation
import MapKit

protocol SearchViewModelDelegate: AnyObject {
    func addressSearching()
    func needUpdateCollectionView()
}
// 관광지 카테고리
enum TripCategory {
    case all
    case tourristSpot
    case food
    case accommodation
}
// 현재 뷰 상태 (loading: 데이터 불러오는중 인 상태, readToLoad: 데이터 불러올 수 있는 상태)
enum ViewState {
    case loading
    case readyToLoad
}
// HTTP네트워크에서 관광지 혹은 날씨 선택해서 불러오기 위한 열거형
enum NetworkingType {
    case trip
    case weather
}

final class SearchViewModel {
    // 주소검색창에 보여지는 데이터배열
    var filteredAddressArray: [LocationDataModel] = [] {
        didSet {
            delegate?.addressSearching()
        }
    }
    // JSON파일로 있는 장소데이터
    var areaDatabase = AreaDatabase()
    weak var delegate: SearchViewModelDelegate?
    // 주소 검색창에서 주소 선택시 해당 변수에 저장후 네트워크 통신 때 사용함
    var selectedSigungu: LocationDataModel?
    // 현재 날씨 보기 선택시 해당 변수에 저장후 네트워크 통신 때 사용함
    var selectedLocationInfo: ConvertedLocationModel?
    
    var locationSearcHandler: LocationSearchHandler
    var defaultWeatherData: ConvertedLocationModel?
    // 무한 스크롤 중 데이터가 더 이상 불러 올 수 없는지 확인하기 위한 변수
    private var AllTripDataLoaded: Bool = false
    // HTTP통신에서 Key값으로 쓰이는 page 변수
    private var currentTripPage: Int = 0 {
        didSet {
            currentTripDataLoadedCount = 50 * currentTripPage
        }
    }
    // 현재 불러온 데이터의 총 개수
    private var currentTripDataLoadedCount: Int = 0
    // 해당 장소의 데이터 총 갯수 (현재 불러온 개수와 비교하여 모두 불러왔는지 확인)
    private var tripDataMaxCount = 0
    // 현재 뷰 상태 정의
    private var viewState = ViewState.readyToLoad
    // 현재 선택된 카테고리 (기본값 .all)
    var currentCategoryState: TripCategory = .all
    // 주소 선택시 불러온 관광지 데이터
    private var tripArray: [TripItem] = []
    // 셀에 뿌려질 데이터로 tripArray에서 필터링하여 저장됨
    var filteredTripArray: [TripItem] = [] {
        didSet {
            delegate?.needUpdateCollectionView()
        }
    }
    // 현재로 부터 1시간 뒤 시간 문자열 구하기
    private var currentFctsTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let afterhour = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        let current = dateFormatter.string(from: afterhour!)
        var arr = current.map{String($0)}
        arr[2] = "0"
        arr[3] = "0"
        return arr.joined()
    }
    // 오늘 날짜 구하기
    private var currentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: Date())
    }
    
    init(locationSearcHandler: LocationSearchHandler) {
        self.locationSearcHandler = locationSearcHandler
    }
    // 랭킹순으로 정렬
    private func sortedTripArray(arr: [TripItem]) -> [TripItem] {
        return arr.sorted { item1, item2 in
            return Int(item1.rankNum)! < Int(item2.rankNum)!
        }
    }
    
    // 해당 카테고리로 필터링하여 저장
    func filteringTrip(type: TripCategory) {
        self.currentCategoryState = type
        switch type {
        case .all:
            filteredTripArray = sortedTripArray(arr: tripArray)
        case .tourristSpot:
            filteredTripArray = sortedTripArray(arr: tripArray.filter{ $0.relatedLargeCategoryName == "관광지" })
        case .food:
            filteredTripArray = sortedTripArray(arr: tripArray.filter{ $0.relatedLargeCategoryName == "음식" })
        case .accommodation:
            filteredTripArray = sortedTripArray(arr: tripArray.filter{ $0.relatedLargeCategoryName == "숙박" })
        }
    }
    // 주소검색창에서 입력 시 필터링된 데이터를 출력하기 위한 메서드
    func filteringAddress(text: String) {
        var output = [LocationDataModel]()
        for element in areaDatabase.data {
            let areaArray = String.separatingString(text: element.areaName, length: text.count)
            let signguArray = String.separatingString(text: element.sigunguName, length: text.count)
            if areaArray.contains(text) || signguArray.contains(text) {
                output.append(element)
            }
        }
        self.filteredAddressArray = output
    }
    // 데이터 불러오기(isFirestLoad true: 처음 불러오기, false: 추가로 불러오기(무한스크롤))
    func fetchData(isFirstLoad: Bool) {
        guard !self.AllTripDataLoaded  else {
            print("All Data Loaded!!")
            return
        }
        guard self.viewState == .readyToLoad else {
            print("-Data loading-")
            return
        }
        // 처음 불러오는거라면 전체 카테고리로 설정 후 이전 데이터를 지우고 불러오기
        // 추가로 불러오는것이라면 카운트 후 불러오기
        if isFirstLoad {
            self.currentCategoryState = .all
            self.tripArray.removeAll()
            self.currentTripPage = 1
            self.AllTripDataLoaded = false
        } else {
            self.currentTripPage += 1
            if currentTripPage >= tripDataMaxCount {
                self.AllTripDataLoaded = true
            }
        }
        loadData(page: currentTripPage, networkType: .trip)
    }
    
    // NetworkManager로부터 데이터 불러오기
    private func loadData(page: Int, networkType: NetworkingType, index: Int? = 0) {
        
        guard let addressName = selectedSigungu else {
            print("data unloaded")
            return
        }
        if networkType == .weather && self.selectedLocationInfo == nil {
            print("weather data didn't prepared")
        }
        // 현재 상태를 불러오는중으로 전환
        viewState = .loading
        
        // 네트워킹 시작
        Task {
            // 두개의 응답 생성
            async let tripResponse = NetworkManager.shared.fetchData(urlCase: .trip, tripKey: addressName, type: TripNetworkResponse.self, page: page)
            async let weatherResponse = NetworkManager.shared.fetchData(urlCase: .weather, weatherKey: self.selectedLocationInfo, type: WeatherNetworkResponse.self, page: page)
            do {
                switch networkType {
                    
                    // 관광지
                case .trip:
                    let result = try await tripResponse
                    // 불러온 관광지 데이터를 저장
                    tripArray.append(contentsOf: result.response.responseBody.items.item)
                    tripDataMaxCount = result.response.responseBody.totalCount
                    filteringTrip(type: currentCategoryState)
                    
                    // 날씨
                case .weather:
                    let result = try await weatherResponse
                    // 불러온 날씨 데이터를 저장
                    guard let arr = result.response.responseBody?.items.item,
                          let idx = index,
                          let nx = self.selectedLocationInfo?.x,
                          let ny = self.selectedLocationInfo?.y
                    else { return }
                    filteredTripArray[idx].weatherModel = convertWeatherData(item: arr, nx: String(nx), ny: String(ny))
                    print(filteredTripArray[idx])
                }
                print("Success")
                // 성공적으로 불러왔다면 지연시간 추가 (무한스크롤 시 너무 많은 호출 방지)
                try await Task.sleep(for: .seconds(2))
                
                // 에러 핸들링
            } catch NetworkError.invalidURL {
                print("invalidURL")
            } catch NetworkError.decodingError {
                print("decodingError")
            } catch NetworkError.missingData {
                print("missingData")
            } catch NetworkError.serverError(let code) {
                print("serverError code: \(code)")
            } catch {
                print("unknown error")
            }
            // 성공 또는 실패 후 데이터 불러오기 가능 상태로 전환
            viewState = .readyToLoad
        }
    }
    // 현재 날씨 보기 선택 시 날씨 불러오는 작업 실행
    func checkCoordinate(index: Int) {
        // 이전에 불러온 데이터가 이미 존재한다면 데이터를 새로 불러오지 않는다.
        print("currentFctsTime: \(currentFctsTime)")
        print("currentDate: \(currentDate)")
        if filteredTripArray[index].isExpanded == false { return }
        if filteredTripArray[index].weatherModel != nil {
            for element in filteredTripArray[index].weatherModel! {
                if element.fcstTime == self.currentFctsTime && element.baseDate == currentDate {
                    
                    return
                }
            }
        }
        Task {
            await getCoordinate(location: filteredTripArray[index], index: index)
        }
        
    }
    // MapKit을 이용하여 해당 지역의 위도 경도를 구한 후 좌표값으로 변환하는 작업을 비동기로 실행
    func getCoordinate(location: TripItem, index: Int) async {
        Task {
            let case1 = location.relatedAreaAddress
            let case2 = location.relatedAreaName
            let case3 = location.areaName
            async let res1 = locationSearcHandler.search(for: case1)
            async let res2 = locationSearcHandler.search(for: case2)
            async let res3 = locationSearcHandler.search(for: case3)
            // 모든 응답값이 에러가 난다면 종료
            // 주소의 정확도는 res1 > res2 > res3
            var result =  await [try? res1, try? res2, try? res3]
            result.filter{ $0 != nil }
            if result.isEmpty { return }
            // 해당 주소의 좌표를 통해 날씨정보를 구하기
            self.selectedLocationInfo = result.first!
            loadData(page: 1, networkType: .weather, index: index)
        }
    }
    // HTTP통신 후 받은 날씨 데이터를 지정한 데이터모델로 변환
    func convertWeatherData(item: [WeatherItem], nx: String, ny: String) -> [WeatherDataModel]?{
        let time = item[0].fcstTime
        let currentWeather = item.filter{$0.fcstTime == time}
        let firstFcstTime = item[0].fcstTime
        let fcstTimes = self.getFcstTimes(fctsTime: firstFcstTime)
        let baseDate = item[0].baseDate
        let temperatures = item.filter{$0.category == "T1H"}
        let winds = item.filter{$0.category == "WSD"}
        let rainAmounts = item.filter{$0.category == "RN1"}
        let rainStates = item.filter{$0.category == "PTY"}
        let skyStates = item.filter{$0.category == "SKY"}
        var output = [WeatherDataModel]()
        
        for i in 0..<6 {
            output.append(WeatherDataModel(baseDate: baseDate,
                                           fcstTime: fcstTimes[i],
                                           nx: nx,
                                           ny: ny,
                                           temp: temperatures[i].fcstValue,
                                           rainAmount: rainAmounts[i].fcstValue,
                                           rainState: rainStates[i].fcstValue,
                                           skyState: skyStates[i].fcstValue,
                                           wind: winds[i].fcstValue))
        }
        return output
    }
    // 기준시간으로 부터 6시간 뒤까지 시간 문자열 배열로 구하기
    private func getFcstTimes(fctsTime: String) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        let time = dateFormatter.date(from: fctsTime)
        var output = [String]()
        for i in 0..<6 {
            let t = Calendar.current.date(byAdding: .hour, value: i, to: time!)
            output.append(dateFormatter.string(from: t!))
        }
        return output
    }
}

// MapKit 검색 기능을 담은 클래스
protocol LocationSearchHandler {
    func search(for query: String) async throws -> ConvertedLocationModel
}

final class LocationSearch: LocationSearchHandler {
    
    func search(for query: String) async throws -> ConvertedLocationModel {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address
        request.region = MKCoordinateRegion(MKMapRect.world)
        
        
        let localSearch = MKLocalSearch(request: request)
        do {
            let response = try await localSearch.start()
            print("MapKit Search Success")
            let lati = response.mapItems[0].placemark.coordinate.latitude
            let long = response.mapItems[0].placemark.coordinate.longitude
            var location = ConvertedLocationModel(lat: lati, lng: long)
            location.convertGRID_GPS(mode: 0, lat_X: lati, lng_Y: long)
            print("\(query) : \(location)")
            return location
        } catch {
            print("MapKit Search Error")
            print(error.localizedDescription)
            throw(error)
        }
    }
    
}

