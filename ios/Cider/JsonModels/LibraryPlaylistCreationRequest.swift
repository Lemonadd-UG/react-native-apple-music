//
//  LibraryPlaylistCreationRequest.swift
//  ReactNativeAppleMusic
//
//  Created by Janik Steegmüller on 19.04.20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

struct LibraryPlaylistCreationRequest: Codable {
    struct Attributes: Codable {
        var description: String
        var name: String
    }
    struct Relationships: Codable {
        var tracks: Data
    }
    struct Data: Codable {
        var data: Array<LibraryPlaylistRequestTrack>
    }
    struct LibraryPlaylistRequestTrack: Codable {
        var id: String
        var type: MediaType
    }
    var attributes: Attributes
    var relationships: Relationships
}
