import { NativeModules } from 'react-native';
const AppleMusic = NativeModules.AppleMusicAPI;

const login = AppleMusic.initClientWithDevToken
AppleMusic.login = () => {
  return login()
}

const getID = AppleMusic.getUserRecordID
AppleMusic.getRecordID = () => {
  return getID()
}

const getCharts = AppleMusic.getCharts
AppleMusic.getCharts = () => {
  return getCharts()
}

const getAlbum = AppleMusic.getAlbum
AppleMusic.getAlbum = (id) => {
  if(albumID == null) {
    return Promise.reject(new Error("albumID cannot be null"));
  }
  return getAlbum(id)
}
