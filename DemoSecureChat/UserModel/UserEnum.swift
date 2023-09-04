//
//  UserEnum.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 9/4/23.
//

import Foundation
import SignalProtocolObjC

enum User: Int {
    case alice
    case bob
    
    var signalAddress: SignalAddress {
        SignalAddress(name: self.name, deviceId: self.deviceId)
    }
    
    var deviceId: Int32 {
        switch self {
        case .alice:
            return 100
        case .bob:
            return 101
        }
    }
    
    var name: String {
        switch self {
        case .alice:
            return "alice"
        case .bob:
            return "bob"
        }
    }
    
    var displayName: String {
        switch self {
        case .alice:
            return "Alice"
        case .bob:
            return "Bob"
        }
    }
}
