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
        if self.AllTripDataLoaded {
            print("All Data Loaded!!")
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
        loadData(page: currentTripPage)
    }
    private func loadData(page: Int) {
        guard let addressName = selectedSigungu,
              let addressInfo = selectedLocationInfo,
              self.viewState == .readyToLoad else {
            return
        }
        viewState = .loading
        Task {
            async let tripResponse = NetworkManager.shared.fetchData(urlCase: .trip, tripKey: addressName, type: TripNetworkResponse.self, page: page)
//            async let weatherResponse = NetworkManager.shared.fetchData(urlCase: .weather, weatherKey: addressInfo, type: WeatherNetworkResponse.self, count: count)
            
            do {
                let result = try await tripResponse
                print("Success")
                tripArray.append(contentsOf: result.response.responseBody.items.item)
//                tripArray = result.response.responseBody.items.item
                tripDataMaxCount = result.response.responseBody.totalCount
                
                filteringTrip(type: currentCategoryState)
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
    
    func didSected(text: String, index: Int) {
        self.selectedSigungu = filteredAddressArray[index]
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

