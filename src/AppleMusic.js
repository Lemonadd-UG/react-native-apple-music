import { NativeModules, Platform } from 'react-native';


const AppleMusic = NativeModules.AppleMusicAPI;

if (Platform.OS == 'ios') {

  AppleMusic.initialize = AppleMusic.setValsAndInit

  AppleMusic.getICloudID = AppleMusic.getUserRecordID

  AppleMusic.getSongCharts = AppleMusic.getCharts

  AppleMusic.getAlbumCharts = AppleMusic.getCharts

  AppleMusic.search = AppleMusic.searchForTerm

  AppleMusic.getUserPlaylists = AppleMusic.getAllUserPlaylists

  AppleMusic.recentPlayed = AppleMusic.getRecentPlayed

  AppleMusic.getSong = AppleMusic.getSong

  AppleMusic.getAlbum = AppleMusic.getAlbum

  AppleMusic.getArtist = AppleMusic.getArtist
  
  AppleMusic.getHeavyRotation = AppleMusic.getHeavyRotation
  
  AppleMusic.getRecommendations = AppleMusic.getUserRecommendations
  
}
export default AppleMusic;
