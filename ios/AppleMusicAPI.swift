//
//  AppleMusicAPI.swift
//  AppleMusicApi-Test
//
//  Created by Janik Steegmüller on 07.07.19.
//  Copyright © 2020 Janik Steegmüller. All rights reserved.
//
import Foundation
import CupertinoJWT
import StoreKit
import PromiseKit
import CloudKit


@objc(AppleMusicAPI)
class AppleMusicAPI: NSObject {

    //MARK: Variables
    // Calculating token
    private var keyID: String?
    private var devTeamID: String?
    private var privateKey: String?

    // Tokens
    private var devToken: String?
    private var userToken: String?

    // Client for communication with AppleMusic
    private var client: CiderClient?

    // CloudController for gaining rights for user specific AppleMusic
    private var controller: SKCloudServiceController = SKCloudServiceController()
    private var musicLibraryPermissionGranted: Bool?


    @objc
    public func isReadyForBasicRequests(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        var isInit: Bool
        isInit = (devToken != nil && client != nil)
        if(isInit){
          resolve(true)
        }
        else{
          reject("Error", "Not ready, please init!" , AppleMusicApiError("Please init first!"))
        }
    }
    
    @objc
    public func isReadyForUserRequests(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        var isInit: Bool
        isInit = (devToken != nil && client != nil && userToken != nil)
        if(isInit){
          resolve(true)
        }
        else{
          reject("Error", "Not ready, please init!" , AppleMusicApiError("Please init first!"))
        }
    }


    /**
    Initialization of API
    - Parameter keyID:      ID of Apple Music key from Apple Developer
    - Parameter devTeamID:  ID of the development-team
    - Parameter privateKey: The private-key associated with the keyID
    */
    @objc
    public func setValsAndInit(_ keyID: String, devTeamID: String, privateKey: String) {
        self.keyID = keyID
        self.devTeamID = devTeamID
        self.privateKey = privateKey

        self.calcDeveloperToken()

        self.musicLibraryPermissionGranted = self.checkIfMusicLibraryPermissionGranted()
        client = CiderClient(storefront: .germany, developerToken: self.devToken!)
    }
    
    //MARK: Calculating and requesting tokens

    /**
    Calculating of the developer-token with the SwiftJWT helper class
    - Throws: JWTError if private-key is malformed
    */
    private func calcDeveloperToken() {
        if (self.devToken == nil && self.privateKey != nil && self.keyID != nil && self.devTeamID != nil) {
            // Assign developer information and token expiration setting
            let jwt = JWT(keyID: self.keyID!, teamID: self.devTeamID!, issueDate: Date(), expireDuration: 15777000)
            do {
                self.devToken = try jwt.sign(with: self.privateKey!)
                // Use the token in the authorization header in your requests connecting to Apple’s API server.
                // e.g. urlRequest.addValue(_ value: "bearer \(token)", forHTTPHeaderField field: "authorization")
            } catch {
                print(error.localizedDescription)
            }
        }
    }


  func requestUserTokenPromise() -> Promise<Void> {
    return Promise { promise in
      self.controller.requestUserToken(forDeveloperToken: self.devToken!) { token, error in
        if (error == nil) {
            self.userToken = token;
            promise.fulfill(());
        } else {
          promise.reject(error!)
      }
    }
  }
}

    // MARK: Permission handling
    /**
    Check if we have the rights to access the users music-library
    - Returns: true if access granted/ false if otherwise
    */
    public func checkIfMusicLibraryPermissionGranted() -> Bool {
        switch SKCloudServiceController.authorizationStatus() {
        case .authorized:
            return true
        default:
            return false
        }
    }


    /**
    Ask user for rights to access the music-library, will show an promt yes/no with
    Privacy - Media Library Usage Description-text
    */
    private func askUserForMusicLibPermission() -> Promise<String> {
      return Promise { promise in
        SKCloudServiceController.requestAuthorization { result in
            switch result {
            case .authorized:
                self.musicLibraryPermissionGranted = true;
                promise.fulfill("authorized")
            case .denied:
                self.musicLibraryPermissionGranted = false;
                promise.fulfill("denied")
            case .restricted:
                self.musicLibraryPermissionGranted = false;
                promise.fulfill("restricted")
            default:
                self.musicLibraryPermissionGranted = false;
                promise.reject(AppleMusicApiError("The authorization type cannot be determined."))
            }
        }
      }
    }

    /**
    Check Apple Music subscription-status

    */
    private func checkSKCloudServiceCapability() -> Promise<Void> {
      return Promise { promise in
        controller.requestCapabilities { (capabilities: SKCloudServiceCapability, error: Error?) in
            if (error == nil) {
              if capabilities.contains(.musicCatalogPlayback){
                promise.fulfill(())
              } else {
                promise.reject(AppleMusicApiError("User has no subscription"))
              }
            } else {
              promise.reject(error!)
          }
        }
      }
    }
    
    @objc
    public func getUserSubscriptionStatus(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        firstly{
            checkSKCloudServiceCapability();
        }.done{
            resolve("Subscribed");
        }.catch{ error in
            reject("Error", error.localizedDescription, error );
        }
    }
    
    @objc
    public func askUserForPermission(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
          firstly{
              askUserForMusicLibPermission()
          }.done{ result in
              resolve(result);
          }.catch{ error in
              reject("Error", error.localizedDescription, error );
          }
      }
    
    @objc
    public func requestUserToken(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
          firstly{
              requestUserTokenPromise()
          }.done{
              self.client = CiderClient(storefront: .germany, developerToken: self.devToken!, userToken: self.userToken!)
              resolve("Ready to go");
          }.catch{ error in
              reject("Error", error.localizedDescription, error );
          }
      }

    // MARK: Actual functions from the API
    /**
    Search for term and return result with callback
    - Parameter searchString: The term to search
    - Parameter offset: The offset (page) you want to receive
    - Parameter callback: Callback for ReactNative
    */
    @objc
    public func searchForTerm(_ searchString: String, offset: Int, type: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            let type = MediaType.init(rawValue: type);
            client!.searchJsonString(term: searchString, limit: 24, offset: offset, types: [type!]) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }
    
    /**
    Return information about a multiple songs
    - Parameter id: The id of the song
    */
    @objc
    public func getSongs(_ ids: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.getObjects(mediaType: .songs, ids: ids) { result, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: result))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }


    /**
    Return information about a specific song
    - Parameter id: The id of the song
    - Parameter callback: Callback for ReactNative
    */
    @objc
    public func getSong(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .songs, id: id, include: nil) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }
    
    /**
    Return information about a specific playlist
    - Parameter id: The id of the song
    */
    @objc
    public func getPlaylist(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .playlists, id: id, include: nil) { result, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: result))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
    Return information about a specific album
    - Parameter id: The id of the album
    - Parameter callback: Callback for ReactNative
    */
    @objc
    public func getAlbum(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .albums, id: id, include: nil) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
    Return information about a specific artist
    - Parameter id: The id of the artist
    - Parameter callback: Callback for ReactNative
    */
    @objc
    public func getArtist(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .artists, id: id, include: nil) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
    Get the heavyRotation ( recently heard songs/playlist/etc.)
    - Parameter callback: Callback for ReactNative
    */
    @objc
    public func getHeavyRotation(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.heavyRotationJsonString(limit: 10) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
     Get the recentPlayed ( recently heard songs/playlist/etc.)
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getRecentPlayed(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.recentPlayedJsonString(limit: 10) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
     Get the charts
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getCharts(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.chartsJsonString(limit: 50, types: [.albums, .songs]) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
     Get all user playlists
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getAllUserPlaylists(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.getAllUserPlaylistsJsonString(limit: 50) { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }
    
    @objc
    public func getUserPlaylist(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        if (client != nil) {
            client!.getUserPlaylistJsonString(id: id){ result, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: result))
                } else{
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }

    /**
     Get user recommendations
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getUserRecommendations(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.recommendationsJsonString { results, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: results))
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }
    
    @objc
    public func addToPlaylist(_ playlistId: String, mediaId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        if ( client != nil) {
            client!.addToPlaylist(playlistId: playlistId, mediaId: mediaId, mediaType: .songs) { (result, error) in
                if( error == nil) {
                    resolve(result)
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }
    
    @objc
    public func newPlaylist(_ name: String, description: String, trackIds: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if ( client != nil) {
            client!.newPlaylist(name: name, description: description, trackIds: trackIds){ (result, error) in
                if( error == nil) {
                    resolve(result)
                } else {
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }
    
    @objc
    public func getSongWithIsrc(_ isrc: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.fetchIsrcJsonString(mediaType: .songs, isrc: isrc) { result, error in
                if (error == nil) {
                    resolve(self.jsonToDic(json: result))
                } else{
                    reject("error", error?.localizedDescription, error)
                }
            }
        }
    }


    @objc
    public func getUserRecordID(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let recordIDName = recordID?.recordName {
                resolve(recordIDName)
            } else {
                reject("error",error?.localizedDescription, error)
            }
        }
    }

    private func jsonToDic(json: String) -> [String: Any]? {
        if let jsonData = json.data(using: .utf8){
            do {
                return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil;
    }
    
    //required for ReactNative
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    // MARK: Claims for Apple Music JWT
    struct AppleMusicClaims: Codable {
        let iss: String
        let iat: Date
        let exp: Date
    }

}
