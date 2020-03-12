//
//  CiderUrlBuilder.swift
//  Cider
//
//  Created by Scott Hoyt on 8/1/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

protocol UrlBuilder {
    func searchRequest(term: String, limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest
    func searchHintsRequest(term: String, limit: Int?, types: [MediaType]?) -> URLRequest
    func fetchRequest(mediaType: MediaType, id: String, include: [Include]?) -> URLRequest
    func relationshipRequest(path: String, limit: Int?, offset: Int?) -> URLRequest
    func heavyRotationRequest(limit: Int?, offset: Int?) -> URLRequest
    func recentPlayedRequest(limit: Int?, offset: Int?) -> URLRequest
    func chartsRequest(limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest
    func userPlaylistsRequest(limit: Int?, offset: Int?) -> URLRequest
    func userRecommendationsRequest(limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest
}

public enum CiderUrlBuilderError: Error {
    case noUserToken
}

// MARK: - Constants

private struct AppleMusicApi {
    // Base
    static let baseURLScheme = "https"
    static let baseURLString = "api.music.apple.com"
    static let baseURLApiVersion = "/v1"

    // Search
    static let searchPath = "v1/catalog/{storefront}/search"
    static let searchHintPath = "v1/catalog/{storefront}/search/hints"

    // Parameteres
    static let termParameter = "term"
    static let limitParameter = "limit"
    static let offsetParameter = "offset"
    static let typesParameter = "types"

    // Fetch
    static let fetchPath = "v1/catalog/{storefront}/{mediaType}/{id}"
    static let fetchInclude = "include"
    
    // User-specific heavy-rotation https://api.music.apple.com/v1/me/history/heavy-rotation
    static let heavyRotationPath = "v1/me/history/heavy-rotation"
    
    // User-specific recent https://api.music.apple.com/v1/me/recent/played
    static let recentPlayedPath = "v1/me/recent/played"
    
    // Private user playlists
    static let userPlaylistsPath = "v1/me/library/playlists"
    
    //Charts of specific country https://api.music.apple.com/v1/catalog/{storefront}/charts
    static let chartsPath = "v1/catalog/us/charts"
    
    //User-specific recommendations
    static let recommendationsPath = "v1/me/recommendations"
    
}

// MARK: - UrlBuilder

struct CiderUrlBuilder: UrlBuilder {

    // MARK: Inputs

    let storefront: Storefront
    let developerToken: String
    var userToken: String?
    private let cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    private let timeout: TimeInterval = 10

    // MARK: Init

    init(storefront: Storefront, developerToken: String, userToken: String) {
        self.storefront = storefront
        self.developerToken = developerToken
        self.userToken = userToken
    }
    
    init(storefront: Storefront, developerToken: String) {
        self.storefront = storefront
        self.developerToken = developerToken
    }

    private var baseApiUrl: URL {
        var components = URLComponents()

        components.scheme = AppleMusicApi.baseURLScheme
        components.host = AppleMusicApi.baseURLString

        return components.url!
    }

    // MARK: Construct urls
    
    private func recommendationsUrl( limit: Int?, offset: Int?, types: [MediaType]?) -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.recommendationsPath
        
        components.apply(limit: limit)
        components.apply(offset: offset)
        components.apply(mediaTypes: types)
        
        return components.url(relativeTo: baseApiUrl)!
    }
    
    private func heavyRotationUrl( limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.heavyRotationPath
        
        components.apply(limit: limit)
        components.apply(offset: offset)
        
        return components.url(relativeTo: baseApiUrl)!
    }
    
    private func userPlaylistsUrl( limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.userPlaylistsPath
        
        components.apply(limit: limit)
        components.apply(offset: offset)
        
        return components.url(relativeTo: baseApiUrl)!
    }

    
    private func recentPlayedUrl( limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()
        
        components.path = AppleMusicApi.recentPlayedPath
        
        components.apply(limit: limit)
        components.apply(offset: offset)
        
        return components.url(relativeTo: baseApiUrl)!
    }


    private func seachUrl(term: String, limit: Int?, offset: Int?, types: [MediaType]?) -> URL {

        // Construct url path

        var components = URLComponents()

        components.path = AppleMusicApi.searchPath.addStorefront(storefront)

        // Construct Query
        components.apply(searchTerm: term)
        components.apply(limit: limit)
        components.apply(offset: offset)
        components.apply(mediaTypes: types)

        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }
    
    private func chartsUrl(limit: Int?, offset: Int?, types: [MediaType]?) -> URL {
        
        var components = URLComponents()
        
        components.path = AppleMusicApi.chartsPath
        
        components.apply(limit: limit)
        components.apply(mediaTypes: types)
        components.apply(offset: offset)
        
        return components.url(relativeTo: baseApiUrl)!
    }

    private func searchHintsUrl(term: String, limit: Int?, types: [MediaType]?) -> URL {

        // Construct url path

        var components = URLComponents()

        components.path = AppleMusicApi.searchHintPath.addStorefront(storefront)

        // Construct Query
        components.apply(searchTerm: term)
        components.apply(limit: limit)
        components.apply(mediaTypes: types)

        // Construct final url
        return components.url(relativeTo: baseApiUrl)!
    }

    private func fetchUrl(mediaType: MediaType, id: String, include: [Include]?) -> URL {
        var components = URLComponents()

        components.path = AppleMusicApi.fetchPath.addStorefront(storefront).addMediaType(mediaType).addId(id)
        components.apply(include: include)

        return components.url(relativeTo: baseApiUrl)!.absoluteURL
    }

    private func relationshipUrl(path: String, limit: Int?, offset: Int?) -> URL {
        var components = URLComponents()

        components.path = path
        components.apply(limit: limit)
        components.apply(offset: offset)

        return components.url(relativeTo: baseApiUrl)!.absoluteURL
    }

    // MARK: Construct requests
    
    func userRecommendationsRequest(limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest {
        let url = recommendationsUrl(limit: limit, offset: offset, types: types)
        return constructRequestWithUserAuth(url: url)
    }

    func heavyRotationRequest(limit: Int?, offset: Int?) -> URLRequest {
        let url = heavyRotationUrl(limit: limit, offset: offset)
        return constructRequestWithUserAuth(url: url)
    }

    func userPlaylistsRequest(limit: Int?, offset: Int?) -> URLRequest {
        let url = userPlaylistsUrl(limit: limit, offset: offset)
        return constructRequestWithUserAuth(url: url)
    }
    
    func chartsRequest(limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest {
        let url = chartsUrl(limit: limit, offset: offset, types: types)
        return constructRequest(url: url)
    }
    
    func recentPlayedRequest(limit: Int?, offset: Int?) -> URLRequest {
        let url = recentPlayedUrl(limit: limit, offset: offset)
        return constructRequestWithUserAuth(url: url)
    }

    func searchRequest(term: String, limit: Int?, offset: Int?, types: [MediaType]?) -> URLRequest {
        let url = seachUrl(term: term, limit: limit, offset: offset, types: types)
        return constructRequest(url: url)
    }

    func searchHintsRequest(term: String, limit: Int?, types: [MediaType]?) -> URLRequest {
        let url = searchHintsUrl(term: term, limit: limit, types: types)
        return constructRequest(url: url)
    }

    func fetchRequest(mediaType: MediaType, id: String, include: [Include]?) -> URLRequest {
        let url = fetchUrl(mediaType: mediaType, id: id, include: include)
        return constructRequest(url: url)
    }

    func relationshipRequest(path: String, limit: Int?, offset: Int?) -> URLRequest {
        let url = relationshipUrl(path: path, limit: limit, offset: offset)
        return constructRequest(url: url)
    }

    private func constructRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request = addAuth(request: request)

        return request
    }
    
    private func constructRequestWithUserAuth(url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request = addAuth(request: request)
        request = try! addUserToken(request: request)
        
        return request
    }

    // MARK: Add authentication

    private func addAuth(request: URLRequest) -> URLRequest {
        var request = request

        let authHeader = "Bearer \(developerToken)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")

        return request
    }

    // TODO: Make this private once we add a request that needs it and can test via that vector.
    func addUserToken(request: URLRequest) throws -> URLRequest {
        guard let userToken = userToken else {
            throw CiderUrlBuilderError.noUserToken
        }

        var request = request
        request.setValue(userToken, forHTTPHeaderField: "Music-User-Token")

        return request
    }
}

// MARK: - Helpers

private extension String {
    func replaceSpacesWithPluses() -> String {
        return replacingOccurrences(of: " ", with: "+")
    }

    func addStorefront(_ storefront: Storefront) -> String {
        return replacingOccurrences(of: "{storefront}", with: storefront.rawValue)
    }

    func addId(_ id: String) -> String {
        return replacingOccurrences(of: "{id}", with: id)
    }

    func addMediaType(_ mediaType: MediaType) -> String {
        return replacingOccurrences(of: "{mediaType}", with: mediaType.rawValue)
    }
}

private extension URLComponents {
    mutating func createQueryItemsIfNeeded() {
        if queryItems == nil {
            queryItems = []
        }
    }

    mutating func apply(searchTerm: String) {
        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.termParameter, value: searchTerm.replaceSpacesWithPluses()))
    }

    mutating func apply(mediaTypes: [MediaType]?) {
        guard let mediaTypes = mediaTypes else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.typesParameter, value: mediaTypes.map { $0.rawValue }.joined(separator: ",")))
    }

    mutating func apply(limit: Int?) {
        guard let limit = limit else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.limitParameter, value: "\(limit)"))
    }

    mutating func apply(offset: Int?) {
        guard let offset = offset else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.offsetParameter, value: "\(offset)"))
    }

    mutating func apply(include: [Include]?) {
        guard let include = include else { return }

        createQueryItemsIfNeeded()
        queryItems?.append(URLQueryItem(name: AppleMusicApi.fetchInclude, value: include.map { $0.rawValue }.joined(separator: ",")))
    }
}
