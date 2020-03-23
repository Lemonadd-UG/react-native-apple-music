import { NativeModules, Platform } from 'react-native';


const AppleMusic = NativeModules.AppleMusicAPI;

if (Platform.OS == 'ios') {

  const initialize = AppleMusic.setValsAndInit
  AppleMusic.initialize = (keyID, teamID, key) => {
    return initialize(keyID, teamID, key)
  }

  const login_basic = AppleMusic.initClientWithDevToken
  AppleMusic.login_basic = () => {
    return login_basic()
  }

  const login = AppleMusic.initClientWithDevTokenAndUserToken
  AppleMusic.login = () => {
    return new Promise((resolve, reject) => {
      login(answer => {
        if (answer === 420) {
          resolve(true)
        } else if (answer === 421) {
          reject("User declined the permission for Apple Music")
        } else {
          reject("Apple Music Subscription is required")
        }
      })
    })
  }

  const getICloudID = AppleMusic.getUserRecordID
  AppleMusic.getICloudID = () => {
    return new Promise((resolve, reject) => {
      getICloudID((answer, rest) => {
        if (answer) {
          try {
            console.log('rest id: ', rest)
            resolve(rest)
          } catch (e) {
            reject(new Error("error trying to get the icloud id"))
          }

        } else {
          reject(new Error(rest))
        }
      })
    })
  }

  const getSongCharts = AppleMusic.getCharts
  AppleMusic.getSongCharts = () => {
    return new Promise((resolve, reject) => {
      getSongCharts((answer, rest) => {
        if (answer) {
          try {
            let _response = JSON.parse(rest)
            let _songs = _response.results.songs[0].data
            resolve(_songs)
          } catch (e) {
            reject(new Error("error trying to get the song charts"))
          }

        } else {
          reject(new Error("error trying to get the song charts"))
        }
      })
    })
  }

  const getAlbumCharts = AppleMusic.getCharts
  AppleMusic.getAlbumCharts = () => {
    return new Promise((resolve, reject) => {
      getAlbumCharts((answer, rest) => {
        if (answer) {
          try {
            let _response = JSON.parse(rest)
            let _albums = _response.results.albums[0].data
            resolve(_albums)
          } catch (e) {
            reject(new Error("error trying to get the albums charts"))
          }

        } else {
          reject(new Error("error trying to get the albums charts"))
        }
      })
    })
  }

  const searchSong = AppleMusic.searchForTerm
  AppleMusic.searchSong = (search) => {
    return new Promise((resolve, reject) => {
      searchSong(search, 0, async (answer, ...rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            let _songs = cb.results.songs.data
            resolve(_songs)
          } catch (e) {
            reject(new Error("error trying to search for songs"))
          }

        } else {
          reject(new Error("error trying to search for songs"))
        }
      })
    })
  }

  const searchAlbum = AppleMusic.searchForTerm
  AppleMusic.searchAlbum = (search) => {
    return new Promise((resolve, reject) => {
      searchAlbum(search, 0, async (answer, ...rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            let _albums = cb.results.albums.data
            resolve(_albums)
          } catch (e) {
            reject(new Error("error trying to search for albums"))
          }

        } else {
          reject(new Error("error trying to search for albums"))
        }
      })
    })
  }

  const searchArtist = AppleMusic.searchForTerm
  AppleMusic.searchArtist = (search) => {
    return new Promise((resolve, reject) => {
      searchArtist(search, 0, async (answer, ...rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            let _artists = cb.results.artists.data
            resolve(_artists)
          } catch (e) {
            reject(new Error("error trying to search for artists"))
          }

        } else {
          reject(new Error("error trying to search for artists"))
        }
      })
    })
  }

  const searchPlaylist = AppleMusic.searchForTerm
  AppleMusic.searchPlaylist = (search) => {
    return new Promise((resolve, reject) => {
      searchPlaylist(search, 0, async (answer, ...rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            let _playlists = cb.results.playlists.data
            resolve(_playlists)
          } catch (e) {
            reject(new Error("error trying to search for playlists"))
          }

        } else {
          reject(new Error("error trying to search for playlists"))
        }
      })
    })
  }

  const getUserPlaylists = AppleMusic.getAllUserPlaylists
  AppleMusic.getUserPlaylists = () => {
    return new Promise((resolve, reject) => {
      getUserPlaylists((answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            console.log(cb)
            const _playlists = cb.data
            resolve(_playlists)
          } catch (e) {
            reject(new Error("error trying to get user playlists"))
          }

        } else {
          reject(new Error("error trying to get user playlists"))
        }
      })
    })
  }

  const recentPlayed = AppleMusic.getRecentPlayed
  AppleMusic.recentPlayed = () => {
    return new Promise((resolve, reject) => {
      recentPlayed((answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            console.log(cb.data)
            const _recentPlayed = cb.data
            resolve(_recentPlayed)
          } catch (e) {
            reject(new Error("error trying to get recent played"))
          }

        } else {
          reject(new Error("error trying to get recent played"))
        }
      })
    })
  }

  const getSong = AppleMusic.getSong
  AppleMusic.getSong = (id) => {
    return new Promise((resolve, reject) => {
      getSong(id, (answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            const _song = cb.data
            resolve(_song)
          } catch (e) {
            reject(new Error("error trying to get song by id"))
          }

        } else {
          reject(new Error("error trying to get song by id"))
        }
      })
    })
  }

  const getAlbum = AppleMusic.getAlbum
  AppleMusic.getAlbum = (id) => {
    return new Promise((resolve, reject) => {
      getAlbum(id, (answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            const _album = cb.data
            resolve(_album)
          } catch (e) {
            reject(new Error("error trying to get album by id"))
          }

        } else {
          reject(new Error("error trying to get album by id"))
        }
      })
    })
  }

  const getArtist = AppleMusic.getArtist
  AppleMusic.getArtist = (id) => {
    return new Promise((resolve, reject) => {
      getArtist(id, (answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            const _artist = cb.data
            resolve(_artist)
          } catch (e) {
            reject(new Error("error trying to get artist by id"))
          }

        } else {
          reject(new Error("error trying to get artist by id"))
        }
      })
    })
  }

  const getHeavyRotation = AppleMusic.getHeavyRotation
  AppleMusic.getHeavyRotation = () => {
    return new Promise((resolve, reject) => {
      getHeavyRotation((answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            console.log(cb.data)
            const _heavyrotation = cb.data
            resolve(_heavyrotation)
          } catch (e) {
            reject(new Error("error trying to get a heavy rotation"))
          }

        } else {
          reject(new Error("error trying to get a heavy rotation"))
        }
      })
    })
  }

  const getRecommendations = AppleMusic.getUserRecommendations
  AppleMusic.getRecommendations = () => {
    return new Promise((resolve, reject) => {
      getRecommendations((answer, rest) => {
        if (answer) {
          try {
            let cb = JSON.parse(rest)
            console.log(cb.data)
            const _recommendations = cb.data
            resolve(_recommendations)
          } catch (e) {
            reject(new Error("error trying to get user recommendations"))
          }

        } else {
          reject(new Error("error trying to get user recommendations"))
        }
      })
    })
  }
}
export default AppleMusic;
