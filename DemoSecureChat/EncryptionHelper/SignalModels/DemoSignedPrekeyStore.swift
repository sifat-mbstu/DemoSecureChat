//
//  DemoSignedPrekeyStore.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/7/23.
//

import Foundation
import SignalProtocolObjC

class DemoSignedPrekeyStore: NSObject, SignalSignedPreKeyStore {
    var preKeys = [UInt32: Data]()
    
    func loadSignedPreKey(withId signedPreKeyId: UInt32) -> Data? {
        print("laod signed prekey id: \(signedPreKeyId) has: \(preKeys[signedPreKeyId] != nil)")
        return preKeys[signedPreKeyId]
    }
    
    func storeSignedPreKey(_ signedPreKey: Data, signedPreKeyId: UInt32) -> Bool {
        print("store signed prekey id: \(signedPreKeyId)")
        preKeys[signedPreKeyId] = signedPreKey
        return true
    }
    
    func containsSignedPreKey(withId signedPreKeyId: UInt32) -> Bool {
        return preKeys[signedPreKeyId] != nil
    }
    
    func removeSignedPreKey(withId signedPreKeyId: UInt32) -> Bool {
        print("remvoe signed prekey id: \(signedPreKeyId)")
        return preKeys.removeValue(forKey: signedPreKeyId) != nil
    }
    
}
