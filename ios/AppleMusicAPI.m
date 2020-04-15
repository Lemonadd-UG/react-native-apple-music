#import <Foundation/Foundation.h>

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AppleMusicAPI, NSObject)

//Api initialization
RCT_EXTERN_METHOD(setValsAndInit:   (NSString)keyID
                                    devTeamID:(NSString)devTeamID
                                    privateKey:(NSString)privateKey)


RCT_EXTERN_METHOD(initClientWithDevToken)
RCT_EXTERN_METHOD(initClientWithDevTokenAndUserToken:   (RCTPromiseResolveBlock)resolve
                                                        reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(isInitialized:    (RCTResponseSenderBlock)callback)


//Api functions
//No login
RCT_EXTERN_METHOD(searchForTerm:    (NSString)term
                                    offset:(int)offset
                                    resolve:(RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSong:  (NSString)id
                            resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getAlbum: (NSString)id
                            resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getArtist:    (NSString)id
                                resolve:(RCTPromiseResolveBlock)resolve
                                reject:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(getCharts:    (RCTPromiseResolveBlock)resolve
                                reject:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(getPlaylist:  (NSString)id
                                resolve:(RCTPromiseResolveBlock)resolve
                                reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSongs: (NSArray)ids
                            resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSongWithIsrc:  (NSString)isrc
                                    resolve:(RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)


//login
RCT_EXTERN_METHOD(getHeavyRotation: (RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getRecentPlayed:  (RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getUserRecommendations:   (RCTPromiseResolveBlock)resolve
                                            reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getAllUserPlaylists:  (RCTPromiseResolveBlock)resolve
                                        reject:(RCTPromiseRejectBlock)reject)


RCT_EXTERN_METHOD(getUserPlaylist:  (NSString)id
                                    resolve:(RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(addToPlaylist:    (NSString)playlistId
                                    mediaId:(NSString)mediaId
                                    resolve:(RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)


//other
RCT_EXTERN_METHOD(getUserRecordID:  (RCTPromiseResolveBlock)resolve
                                    reject:(RCTPromiseRejectBlock)reject)

@end
