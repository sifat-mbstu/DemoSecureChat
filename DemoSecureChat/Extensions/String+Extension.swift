//
//  String+Extension.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/9/23.
//

import Foundation

extension String {
    var base64Data: Data? {
        Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
}

extension Data {
    var base64String: String {
        base64EncodedString(options: .lineLength76Characters)
    }
}
