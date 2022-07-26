//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Roberto Cruz on 22/07/22.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    var description: String {
        return "\n Result - Kind: \(kind ?? "none"), Name: \(name), Artist Name: \(artistName ?? "None"), TrackPrice: \(trackPrice ?? 0.0), Currency: \(currency), storeURL: \(storeURL ?? "none"), Genre: \(genre)"
    }
    
    var artistName: String? = ""
    var trackName: String? = ""
    var kind: String? = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    // MARK: Use of coding keys for renaming JSON
    var imageSmall = ""
    var imageLarge = ""
    var storeURL: String? = ""
    var genre = ""
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case storeURL = "trackViewUrl"
        case genre = "primaryGenreName"
        case kind, artistName, trackName, trackPrice, currency
    }
    
    var name: String {
        return trackName ?? ""
    }
}


