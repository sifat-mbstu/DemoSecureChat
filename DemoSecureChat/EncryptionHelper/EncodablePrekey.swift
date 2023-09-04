//
//  EncodablePrekey.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/21/23.
//

import Foundation
import SignalProtocolObjC

class EncodablePrekey: Codable {
    
    var registrationId: Int
    var deviceId: Int
    var preKeyId: Int
    var signedPreKeyId: Int
    var preKeyPublic: Data
    var signedPreKeyPublic: Data
    var signature: Data
    var identityKey: Data
    
    init(from prekeyBundle: SignalPreKeyBundle) {
        registrationId  = Int(prekeyBundle.registrationId)
        deviceId  = Int(prekeyBundle.deviceId)
        preKeyId = Int(prekeyBundle.preKeyId)
        signedPreKeyId = Int(prekeyBundle.signedPreKeyId)
        preKeyPublic = prekeyBundle.preKeyPublic
        signedPreKeyPublic = prekeyBundle.signedPreKeyPublic
        signature = prekeyBundle.signature
        identityKey = prekeyBundle.identityKey
    }
    
    func converToSingleBundle() -> SignalPreKeyBundle {
        
        return try! SignalPreKeyBundle(registrationId       : UInt32(registrationId),
                                       deviceId             : UInt32(deviceId),
                                       preKeyId             : UInt32(preKeyId),
                                       preKeyPublic         : preKeyPublic,
                                       signedPreKeyId       : UInt32(signedPreKeyId),
                                       signedPreKeyPublic   : signedPreKeyPublic,
                                       signature            : signature,
                                       identityKey          : identityKey)
        
    }
}
