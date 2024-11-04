//
//  SearchViewModel.swift
//  KoreaTripRank
//
//  Created by 이민재 on 11/4/24.
//

import Foundation

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
}
