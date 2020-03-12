//
//  AppleMusicApiError.swift
//  AwesomeApp
//
//  Created by Janik Steegmüller on 19.12.19.
//  Copyright © 2020 Janik Steegmüller. All rights reserved.
//
struct AppleMusicApiError: Error {
   static let USER_DECLINED_PERMISSION: Int = 421
   static let USER_IS_NO_APPLE_MUSIC_SUBSCRIBER:    Int = 422
   static let DEVELOPER_TOKEN_IS_MISSING: Int = 424
   static let SKCLOUDSERVICE_FATAL_ERROR: Int = 423
   let id: Int
 }
