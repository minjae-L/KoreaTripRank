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

enum TripCategory {
    case all
    case tourristSpot
    case food
    case accommodation
}

enum ViewState {
    case loading
    case readyToLoad
}

enum NetworkingType {
    case trip
    case weather
}

final class SearchViewModel {
    
    var filteredAddressArray: [LocationDataModel] = [] {
        didSet {
            delegate?.addressSearching()
        }
    }
    var areaDatabase = AreaDatabase()
    weak var delegate: SearchViewModelDelegate?
    var selectedSigungu: LocationDataModel?
    var selectedLocationInfo: ConvertedLocationModel?
    var locationSearcHandler: LocationSearchHandler
    var defaultWeatherData: ConvertedLocationModel?
    private var AllTripDataLoaded: Bool = false
    private var currentTripPage: Int = 0 {
        didSet {
            currentTripDataLoadedCount = 50 * currentTripPage
        }
    }
    private var currentTripDataLoadedCount: Int = 0
    private var tripDataMaxCount = 0
    private var viewState = ViewState.readyToLoad
    var currentCategoryState: TripCategory = .all
    
    private var tripArray: [TripItem] = []
    var filteredTripArray: [TripItem] = [] {
        didSet {
            delegate?.needUpdateCollectionView()
        }
    }
    
    init(locationSearcHandler: LocationSearchHandler) {
        self.locationSearcHandler = locationSearcHandler
    }
    
    private func sortedTripArray(arr: [TripItem]) -> [TripItem] {
        return arr.sorted { item1, item2 in
            return Int(item1.rankNum)! < Int(item2.rankNum)!
        }
    }
    
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
    
    func fetchData(isFirstLoad: Bool) {
        guard !self.AllTripDataLoaded  else {
            print("All Data Loaded!!")
            return
        }
        guard self.viewState == .readyToLoad else {
            print("-Data loading-")
            return
        }
        
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
    
    private func loadData(page: Int, networkType: NetworkingType, index: Int? = 0) {
        
        guard let addressName = selectedSigungu else {
            print("data unloaded")
            return
        }
        if networkType == .weather && self.selectedLocationInfo == nil {
            print("weather data didn't prepared")
        }
        
        viewState = .loading
        
        Task {
            async let tripResponse = NetworkManager.shared.fetchData(urlCase: .trip, tripKey: addressName, type: TripNetworkResponse.self, page: page)
            async let weatherResponse = NetworkManager.shared.fetchData(urlCase: .weather, weatherKey: self.selectedLocationInfo, type: WeatherNetworkResponse.self, page: page)
            do {
                switch networkType {
                case .trip:
                    let result = try await tripResponse
                    tripArray.append(contentsOf: result.response.responseBody.items.item)
                    tripDataMaxCount = result.response.responseBody.totalCount
                    filteringTrip(type: currentCategoryState)
                case .weather:
                    let result = try await weatherResponse
                    
                    guard let arr = result.response.responseBody?.items.item,
                          let idx = index,
                          let nx = self.selectedLocationInfo?.x,
                          let ny = self.selectedLocationInfo?.y
                    else { return }
                    filteredTripArray[idx].nx = String(nx)
                    filteredTripArray[idx].ny = String(ny)
                    filteredTripArray[idx].weatherModel = convertWeatherData(item: arr)
                    print(filteredTripArray[idx])
                }
                print("Success")
                try await Task.sleep(for: .seconds(2))
                viewState = .readyToLoad
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
        }
    }
    
    func checkCoordinate(index: Int) {
        Task {
            await print(getCoordinate(location: filteredTripArray[index], index: index))
        }
        
    }
    
    func getCoordinate(location: TripItem, index: Int) async {
        Task {
            let case1 = location.relatedAreaAddress
            let case2 = location.relatedAreaName
            let case3 = location.areaName
            async let res1 = locationSearcHandler.search(for: case1)
            async let res2 = locationSearcHandler.search(for: case2)
            async let res3 = locationSearcHandler.search(for: case3)
            
            var result =  await [try? res1, try? res2, try? res3]
            result.filter{ $0 != nil }
            if result.isEmpty { return }
            self.selectedLocationInfo = result.first!
            loadData(page: 1, networkType: .weather, index: index)
        }
    }
    
    func didSected(text: String, index: Int) {
        self.selectedSigungu = filteredAddressArray[index]
    }
    
    func convertWeatherData(item: [WeatherItem]) -> WeatherDataModel?{
        let time = item[0].fcstTime
        let currentWeather = item.filter{$0.fcstTime == time}
        
        guard let temperature = currentWeather.filter{$0.category == "T1H"}.first?.fcstValue,
            let wind = currentWeather.filter{$0.category == "WSD"}.first?.fcstValue,
            var rainAmount = currentWeather.filter{$0.category == "RN1"}.first?.fcstValue,
            var rainState = currentWeather.filter{$0.category == "PTY"}.first?.fcstValue,
            var skyState = currentWeather.filter{$0.category == "SKY"}.first?.fcstValue 
        else {
                return nil
            }
        if rainAmount == "강수없음" {
            rainAmount = "0"
        }
        switch rainState {
        case "0":
            rainState = "없음"
        case "1":
            rainState = "비"
        case "2":
            rainState = "비/눈"
        case "5":
            rainState = "빗방울"
        case "6":
            rainState = "빗방울 / 눈날림"
        case "7":
            rainState = "눈날림"
        default:
            break
        }
        switch skyState {
        case "1":
            skyState = "맑음"
        case "3":
            skyState = "구름많음"
        case "4":
            skyState = "흐림"
        default:
            break
        }
        
        return WeatherDataModel(temp: temperature, rainAmount: rainAmount, rainState: rainState, skyState: skyState, wind: wind)
    }
    
}

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

