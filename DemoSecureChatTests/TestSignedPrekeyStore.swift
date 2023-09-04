

import Foundation
import SignalProtocolObjC

class TestSignedPreKeyStore: NSObject, SignalSignedPreKeyStore {
    var preKeys = [UInt32: Data]()
    
    func loadSignedPreKey(withId signedPreKeyId: UInt32) -> Data? {
        return preKeys[signedPreKeyId]
    }
    
    func storeSignedPreKey(_ signedPreKey: Data, signedPreKeyId: UInt32) -> Bool {
        preKeys[signedPreKeyId] = signedPreKey
        return true
    }
    
    func containsSignedPreKey(withId signedPreKeyId: UInt32) -> Bool {
        return preKeys[signedPreKeyId] != nil
    }
    
    func removeSignedPreKey(withId signedPreKeyId: UInt32) -> Bool {
        return preKeys.removeValue(forKey: signedPreKeyId) != nil
    }
    
    
}
