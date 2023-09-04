//
//  TestPreKeyStore.swift
//  DemoSecureChatTests
//
//  Created by Sifatul Islam on 8/3/23.
//

import Foundation
import SignalProtocolObjC

class TestPreKeyStore: NSObject, SignalPreKeyStore {
    private var preKeys = [UInt32 : Data]()
    
    func loadPreKey(withId preKeyId: UInt32) -> Data? {
        return preKeys[preKeyId]
    }
    
    func storePreKey(_ preKey: Data, preKeyId: UInt32) -> Bool {
        preKeys[preKeyId] = preKey
        return true
    }
    
    func containsPreKey(withId preKeyId: UInt32) -> Bool {
        return preKeys[preKeyId] != nil
    }
    
    func deletePreKey(withId preKeyId: UInt32) -> Bool {
        return preKeys.removeValue(forKey: preKeyId) != nil
    }
}

