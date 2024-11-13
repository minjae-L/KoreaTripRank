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
    
    var completer = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    func filtering(text: String) {
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
    private func search(for suggestionCompletion: MKLocalSearchCompletion) async throws {
        let searchRequest = MKLocalSearch.Request(completion: suggestionCompletion)
        searchRequest.region = MKCoordinateRegion(MKMapRect.world)
        searchRequest.resultTypes = .address
        
        let localSearch = MKLocalSearch(request: searchRequest)
        do {
            let response = try await localSearch.start()
            print("MapKit Search Success")
            let lati = response.mapItems[0].placemark.coordinate.latitude
            let long = response.mapItems[0].placemark.coordinate.longitude
            var location = ConvertedLocationModel(lat: lati, lng: long)
            location.convertGRID_GPS(mode: 0, lat_X: lati, lng_Y: long)
            selectedLocationInfo = location
            self.loadData()
        } catch {
            print("MapKit Search Error")
            print(error.localizedDescription)
        }
        
    }
    
    func didSected(text: String, index: Int) {
        completer.queryFragment = text
        completer.resultTypes = .address
        self.selectedSigungu = filteredAddressArray[index]
        
    }
    
    func getLocation(results: [MKLocalSearchCompletion]) {
        Task {
            try await self.search(for: results[0])
        }
    }
}
