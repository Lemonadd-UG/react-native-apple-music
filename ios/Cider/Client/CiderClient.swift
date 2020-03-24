//
//  CiderClient.swift
//  Cider
//
//  Created by Scott Hoyt on 8/4/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

/// A client for submitting requests to the Apple Music API.
public struct CiderClient {
    private let urlBuilder: UrlBuilder
    private let fetcher: UrlFetcher

    // MARK: URLFetcher

    /**
     Default `UrlFetcher`

     A `URLSession` with the default `URLSessionConfiguration`
     */
    public static var defaultURLFetcher: UrlFetcher {
        return URLSession(configuration: URLSessionConfiguration.default)
    }

    // MARK: Initialization

    init(urlBuilder: UrlBuilder, urlFetcher: UrlFetcher = CiderClient.defaultURLFetcher) {
        self.urlBuilder = urlBuilder
        self.fetcher = urlFetcher
    }

    /**
     Initialize a `CiderClient`

     - parameters:
       - storefront: The `Storefront` to submit requests to.
       - developerToken: The Apple Music developer token to use in requests.
       - userToken: The Apple Music user token to use in requests.
       - urlFetcher: The `UrlFetcher` to use for processing requests. Defaults to a `URLSession` with the default `URLSessionConfiguration`.
     */
    public init(storefront: Storefront, developerToken: String, urlFetcher: UrlFetcher = CiderClient.defaultURLFetcher) {
        let urlBuilder = CiderUrlBuilder(storefront: storefront, developerToken: developerToken)
        self.init(urlBuilder: urlBuilder, urlFetcher: urlFetcher)
    }
    
    public init(storefront: Storefront, developerToken: String, userToken: String, urlFetcher: UrlFetcher = CiderClient.defaultURLFetcher) {
        let urlBuilder = CiderUrlBuilder(storefront: storefront, developerToken: developerToken, userToken: userToken)
        self.init(urlBuilder: urlBuilder, urlFetcher: urlFetcher)
    }


    // MARK: Search

    /**
     Get user recommendations
    
     */
    public func recommendationsJsonString(limit: Int? = nil, offset: Int? = nil, types: [MediaType]? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.userRecommendationsRequest(limit: limit, offset: offset, types: types)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    
    /**
     Get heavy-rotation as json from user
     
     */
    public func heavyRotationJsonString(limit: Int? = nil, offset: Int? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.heavyRotationRequest(limit: limit, offset: offset)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    /**
     Fetch media via isrc
     
     */
    public func fetchIsrcJsonString(mediaType: MediaType, isrc: String, include: [Include]? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.fetchIsrcRequest(mediaType: mediaType, isrc: isrc, include: include)
        fetcher.fetch(request: request) { (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    public func getObjects(mediaType: MediaType, ids: [String], include: [Include]? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.getObjectsRequest(mediaType: mediaType, ids: ids, include: include)
        fetcher.fetch(request: request) { (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    /**
     Get recent played as json from user
     
     */
    public func recentPlayedJsonString(limit: Int? = nil, offset: Int? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.recentPlayedRequest(limit: limit, offset: offset)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    /**
    Get all playlists from user as json
     
    */
    public func getAllUserPlaylistsJsonString(limit: Int? = nil, offset: Int? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.allUserPlaylistsRequest(limit: limit, offset: offset)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    public func getUserPlaylistJsonString(id: String, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.userPlaylistRequest(id: id)
        fetcher.fetch(request: request) { (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }


    /**
     Get charts as json
     
     */
    public func chartsJsonString(limit: Int? = nil, offset: Int? = nil, types: [MediaType]? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.chartsRequest(limit: limit, offset: offset, types: types)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    /**
    Get search as json
 
    */
    public func searchJsonString(term: String, limit: Int? = nil, offset: Int? = nil, types: [MediaType]? = nil, completion: @escaping (String, Error?) -> Void) {
        let request = urlBuilder.searchRequest(term: term, limit: limit, offset: offset, types: types)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
    
    public func addToPlaylist(playlistId: String, mediaId: String, mediaType: MediaType, completion: @escaping (String, Error?) -> Void){
        let request = urlBuilder.addToPlaylistRequest(playlistId: playlistId, mediaId: mediaId, mediaType: mediaType)
        fetcher.fetch(request: request) {(data, error, response) in
            guard data != nil else {
                completion("", error)
                return
            }
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            completion(String(httpResponse.statusCode) , nil)
        }
    }
    
    public func getCatalogObjectWithId(mediaType: MediaType, id: String, include:[Include]? ,completion: @escaping (String, Error?) -> Void){
        let request = urlBuilder.fetchRequest(mediaType: mediaType, id: id, include: include)
        fetcher.fetch(request: request){ (data, error, response) in
            guard let data = data else {
                completion("", error)
                return
            }
            completion(String.init(data: data, encoding: .utf8) ?? "error decoding", nil)
        }
    }
 }
