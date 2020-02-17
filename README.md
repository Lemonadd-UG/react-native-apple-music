<h1 align="center">

<p align="center"><img src="https://drive.google.com/uc?export=view&id=19zk8p2z3K_q_pKaJ8AUnmdkUym-BPPDr" width="300" height="80" ></p>

<p align="center">
  <a href="https://www.npmjs.com/package/react-native-about-libraries"><img src="http://img.shields.io/npm/v/react-native-about-libraries.svg?style=flat" /></a>
  <a href="https://github.com/prscX/react-native-about-libraries/pulls"><img alt="PRs Welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" /></a>
  <a href="https://github.com/prscX/react-native-about-libraries#License"><img src="https://img.shields.io/npm/l/react-native-about-libraries.svg?style=flat" /></a>
</p>


React Native Apple Music by Bouncy
</h1>

The Apple Music API is a web service that lets you access information about the media found in the Apple Music Catalog. Here's what each one includes:


Use this service to retrieve information about albums, songs, artists, playlists, music videos, Apple Music stations, ratings, charts, recommendations, and the user's most recently played content. With proper authorization from the user, you can also create or modify playlists and apply ratings to the user's content.

Here's a quick overview of functionalities supported:

* Get the Charts of an specific Country or global
* Get recommendations for an user
* Get the user's most recently played content
* Create a Playlist
* Modify Users Playlists

## 📖 Getting started

`npm install react-native-apple-music --save`

or

`yarn add react-native-apple-music`

### Mostly automatic installation

`$ react-native link react-native-apple-music`

## 💻 Usage

```javascript
import ReactNativeAppleMusic from 'react-native-react-native-apple-music';

```

## 💡 Initialization/Authorization Methods
- **setValsAndInit**( *keyID*, *teamID*, *Key* )

	Initializes the Spotify module and resumes a logged in session if there is one. This must be the first method you call when using this module.

	- *Parameters*

		- **keyID** - (*Required*) an object with options to pass to the Spotify Module
		- **teamID** - (*Required*) Your spotify application's client ID that you registered with spotify [here](https://developer.spotify.com/dashboard/applications)
		- **Key** - (*Required*) Your spotify application's client ID that you registered with spotify [here](https://developer.spotify.com/dashboard/applications)

	- *Returns*

		- A *Promise* that resolves to a boolean when the module finishes initialization, indicating whether or not a session was automatically logged back in

- **initClientWithDevToken**()

	Login every Apple User with your Key.
  User can call non-personlised api calls like getCharts etc.
  Calls like getHeavyRotation are not possible

	- *Returns*

		- *420* if the client is logged in
        - *421* user declined the permission for Apple Music.
		- *422* if has no Apple Music Subscription


- **initClientWithDevTokenAndUserToken**()   (*Apple Music Subscription Required*)

	Login user with Apple Music Subscription

	- *Returns*

		- *420* if the client is logged in
        - *421* user declined the permission for Apple Music.
		- *422* if has no Apple Music Subscription


## TODO

* Autodetect installed packages
* Auto Font Scaling


## ✨ Credits


## 🤔 How to contribute
Have an idea? Found a bug? Please raise to [ISSUES](https://github.com/Lemonadd-UG/react-native-apple-music/issues).
Contributions are welcome and are greatly appreciated! Every little bit helps, and credit will always be given.

## 💖 Support Bouncy

[AppStore](https://apps.apple.com/us/app/bouncy-social-music-plattform/id1435616268?ls=1)

[Google Play Store](https://play.google.com/store/apps/details?id=com.thebouncyapp)


Thanks! ❤️
