//
//  LibraryPlaylistRequestTrack.swift
//  react-native-apple-music
//
//  Created by Janik Steegmüller on 21.03.20.
//

import Foundation

struct LibraryPlaylistRequestTrack: Codable {
    struct Media: Codable {
        var id: String
        var type: MediaType
    }
    
    var data: Array<Media>
}
