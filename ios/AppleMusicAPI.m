#import <Foundation/Foundation.h>

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AppleMusicAPI, NSObject)

//Api initialization
RCT_EXTERN_METHOD(setValsAndInit:(NSString)keyID
            devTeamID:(NSString)devTeamID
            privateKey:(NSString)privateKey)


RCT_EXTERN_METHOD(initClientWithDevToken)
RCT_EXTERN_METHOD(initClientWithDevTokenAndUserToken:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(isInitialized:(RCTResponseSenderBlock)callback)


//Api functions
//No login
RCT_EXTERN_METHOD(searchForTerm:(NSString)term
                  offset:(int)offset
                  callback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(getSong:(NSString)id
                  callback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(getAlbum:(NSString)id
                  callback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(getArtist:(NSString)id
                  callback:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(getCharts:(RCTResponseSenderBlock)callback)

RCT_EXTERN_METHOD(fetchSongWithIsrc:(NSString)isrc
                  callback:(RCTResponseSenderBlock)callback)


//login
RCT_EXTERN_METHOD(getHeavyRotation:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(getRecentPlayed:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(getUserRecommendations:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(getAllUserPlaylists:(RCTResponseSenderBlock)callback)


//other
RCT_EXTERN_METHOD(getUserRecordID:(RCTResponseSenderBlock)callback)

@end
