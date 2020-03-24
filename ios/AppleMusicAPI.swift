//
//  AppleMusicAPI.swift
//  AppleMusicApi-Test
//
//  Created by Janik Steegmüller on 07.07.19.
//  Copyright © 2020 Janik Steegmüller. All rights reserved.
//
import Foundation
import SwiftJWT
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
    public func isInitialized(_ callback: @escaping RCTResponseSenderBlock) {
        var isInit: Bool
        isInit = (devToken != nil && userToken != nil && client != nil)
        callback([isInit])
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
    }

    //MARK: Init of cider-client
    /**
    Initialization of client only with developer-token
    */
    @objc
    public func initClientWithDevToken() {
        client = CiderClient(storefront: .germany, developerToken: self.devToken!)
    }

    /**
    Initialization of client with developer-token and user-token
    for access of private AppleMusic library
    - Parameter callback: func uses web-request for getting the token, callback for result (success/failure)
                          for ReactNative
    */
    @objc
    public func initClientWithDevTokenAndUserToken(_ callback: @escaping RCTResponseSenderBlock) {
        if(self.userToken == nil) {
            getUserToken { result, status in
                if (status == 420) {
                    self.client = CiderClient(storefront: .germany, developerToken: self.devToken!, userToken: self.userToken!)
                }
                callback([status])
            }
            return
        }
        callback([420])
        return
    }

    //MARK: Calculating and requesting tokens

    /**
    Calculating of the developer-token with the SwiftJWT helper class
    - Throws: JWTError if private-key is malformed
    */
    private func calcDeveloperToken() {
        if (devToken == nil) {

            //Setting the values for calculating JWT
            let amJWTHeader = Header(kid: self.keyID!)
            let amJWTPayload = amClaims(iss: self.devTeamID!, iat: Date(), exp: Date().addingTimeInterval(15777000))
            var amJWT = JWT(header: amJWTHeader, claims: amJWTPayload)

            //Sign created JWT with privateKey (= developerToken) and return
            let jwtSigner = JWTSigner.es256(privateKey: self.privateKey!.data(using: .utf8)!)
            do {
                devToken = try amJWT.sign(using: jwtSigner)
            } catch {
                print("AppleMusicAPI: There was an error calculating your developmentToken, is the PrivateKey in the right format?")
            }
        }
    }

    /**
    Request for user-token
    - Parameter completion: callback with
                                - String: reason for success/failure
                                - 0...20 Error occured in SKCloudServiceController (see https://developer.apple.com/documentation/storekit/skerror/code)
                                - 420 success
                                - 421 User has declined permission
                                - 422 The device is not able to playback Apple Music catalog tracks (No Apple Music subscriber)
                                - 424 Dev.-token is missing
                                - 423 Apple completly messed up in SKCloudServiceController
    */
    private func getUserToken(completion: @escaping (String, Int) -> Void) {
      if self.devToken == nil {
        completion("AppleMusicAPI: Client is not initialized! Development token is missing!", 424)
        return
      }
      firstly {
        askUserForMusicLibPermission()
      }.then {
        self.checkSKCloudServiceCapability()
      }.then {
        self.requestUserTokenPromise()
      }.done { userToken in
        self.userToken = userToken
        completion("AppleMusicAPI: success, user-token is: " + self.userToken!, 420)
      }.catch { error in
        let appleMusicApiError = error as? AppleMusicApiError
        let code = appleMusicApiError?.id ?? AppleMusicApiError.SKCLOUDSERVICE_FATAL_ERROR
        completion("Apple Music Api error: " + String(code), code)
      }
  }

  func requestUserTokenPromise() -> Promise<String?> {
    return Promise { promise in
      self.controller.requestUserToken(forDeveloperToken: self.devToken!) { token, error in
        if (error == nil) {
          promise.fulfill(token)
        } else {
          let skError = error as? SKError
          promise.reject(AppleMusicApiError(id: skError?.errorCode ?? AppleMusicApiError.SKCLOUDSERVICE_FATAL_ERROR))
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
    private func askUserForMusicLibPermission() -> Promise<Void> {
      return Promise { promise in
        SKCloudServiceController.requestAuthorization { result in
            switch result {
            case .authorized:
                self.musicLibraryPermissionGranted = true;
                promise.fulfill(())
            case .denied:
                print("Permission denied!")
                self.musicLibraryPermissionGranted = false;
                promise.reject(AppleMusicApiError(id: AppleMusicApiError.USER_DECLINED_PERMISSION))
            default:
                print("Permission not available!")
                self.musicLibraryPermissionGranted = false;
                promise.reject(AppleMusicApiError(id: AppleMusicApiError.USER_DECLINED_PERMISSION))
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
                promise.reject(AppleMusicApiError(id: AppleMusicApiError.USER_IS_NO_APPLE_MUSIC_SUBSCRIBER))
              }
            } else {
              let skError = error as? SKError
              promise.reject(AppleMusicApiError(id: skError?.errorCode ?? AppleMusicApiError.SKCLOUDSERVICE_FATAL_ERROR))
          }
        }
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
    public func searchForTerm(_ searchString: String, offset: Int, callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.searchJsonString(term: searchString, limit: 24, offset: offset) { results, error in
                if (error == nil) {
                  callback([true, [results]])
                } else {
                    callback([false, [error.debugDescription]])
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
                    resolve(result)
                } else {
                    reject("Error fetching", "Error fetching", error)
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
    public func getSong(_ id: String, callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .songs, id: id, include: nil) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
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
                    resolve(result)
                } else {
                    reject("Error fetching", "Error fetching", error)
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
    public func getAlbum(_ id: String, callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .albums, id: id, include: nil) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
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
    public func getArtist(_ id: String, callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.getCatalogObjectWithId(mediaType: .artists, id: id, include: nil) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
                }
            }
        }
    }

    /**
    Get the heavyRotation ( recently heard songs/playlist/etc.)
    - Parameter callback: Callback for ReactNative
    */
    @objc
    public func getHeavyRotation(_ callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.heavyRotationJsonString(limit: 10) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
                }
            }
        }
    }

    /**
     Get the recentPlayed ( recently heard songs/playlist/etc.)
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getRecentPlayed(_ callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.recentPlayedJsonString(limit: 10) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
                }
            }
        }
    }

    /**
     Get the charts
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getCharts(_ callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.chartsJsonString(limit: 50, types: [.albums, .songs]) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
                }
            }
        }
    }

    /**
     Get all user playlists
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getAllUserPlaylists(_ callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.getAllUserPlaylistsJsonString(limit: 50) { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
                }
            }
        }
    }
    
    @objc
    public func getUserPlaylist(_ id: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        if (client != nil) {
            client!.getUserPlaylistJsonString(id: id){ result, error in
                if (error == nil) {
                    resolve(result)
                } else{
                    reject("Error fetching", "Error fetching", error)
                }
            }
        }
    }

    /**
     Get user recommendations
     - Parameter callback: Callback for ReactNative
     */
    @objc
    public func getUserRecommendations(_ callback: @escaping RCTResponseSenderBlock) {
        if (client != nil) {
            client!.recommendationsJsonString { results, error in
                if (error == nil) {
                    callback([true, [results]])
                } else {
                    callback([false, error.debugDescription])
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
                    reject("Error adding", "Error adding", error)
                }
            }
        }
    }
    
    @objc
    public func getSongWithIsrc(_ isrc: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if (client != nil) {
            client!.fetchIsrcJsonString(mediaType: .songs, isrc: isrc) { result, error in
                if (error == nil) {
                    resolve(result)
                } else{
                    reject("Error fetching", "Error fetching", error)
                }
            }
        }
    }


  @objc
  public func getUserRecordID(_ callback: @escaping RCTResponseSenderBlock) {
    CKContainer.default().fetchUserRecordID { recordID, error in
      if let recordIDName = recordID?.recordName {
        callback([true, recordIDName])
      } else {
        callback([false, "Failure, user not logged in in iCloud"] )
      }
    }
  }

    //required for ReactNative
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }

    // MARK: Claims for Apple Music JWT
    struct amClaims: Claims {
        let iss: String
        let iat: Date
        let exp: Date
    }

}
