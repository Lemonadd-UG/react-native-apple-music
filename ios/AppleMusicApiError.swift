//
//  AppleMusicApiError.swift
//  AwesomeApp
//
//  Created by Janik Steegmüller on 19.12.19.
//  Copyright © 2020 Janik Steegmüller. All rights reserved.
//
struct AppleMusicApiError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
