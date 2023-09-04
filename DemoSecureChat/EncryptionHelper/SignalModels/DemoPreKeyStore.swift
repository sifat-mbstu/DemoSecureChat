//
//  DemoPreKeyStore.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/7/23.
//

import Foundation
import SignalProtocolObjC

class DemoPreKeyStore: NSObject, SignalPreKeyStore {
    private var preKeys = [UInt32 : Data]()
    
    func loadPreKey(withId preKeyId: UInt32) -> Data? {
        print("laod prekey id: \(preKeyId) has: \(preKeys[preKeyId] != nil)")
        return preKeys[preKeyId]
    }
    
    func storePreKey(_ preKey: Data, preKeyId: UInt32) -> Bool {
        print("store prekey id: \(preKeyId)")
        preKeys[preKeyId] = preKey
        return true
    }
    
    func containsPreKey(withId preKeyId: UInt32) -> Bool {
        return preKeys[preKeyId] != nil
    }
    
    func deletePreKey(withId preKeyId: UInt32) -> Bool {
        print("remove prekey id: \(preKeyId)")
        return preKeys.removeValue(forKey: preKeyId) != nil
    }
}

