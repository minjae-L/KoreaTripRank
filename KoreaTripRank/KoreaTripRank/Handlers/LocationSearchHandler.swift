//
//  LocationSearchHandler.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/24/24.
//

import Foundation
import MapKit

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
