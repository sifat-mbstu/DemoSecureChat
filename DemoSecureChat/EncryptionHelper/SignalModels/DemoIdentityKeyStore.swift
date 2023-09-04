//
//  DemoIdentityKeyStore.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/7/23.
//


import Foundation
import SignalProtocolObjC

class DemoIdentityKeyStore: NSObject, SignalIdentityKeyStore {
    var identityKeys = [String: Data]()
    var identityKey:SignalIdentityKeyPair?
    let registerID:UInt32
    
    override init() {
        registerID = UInt32.random(in: 0...1000000)
        let storage = SignalStorage()
        guard let context = SignalContext(storage: storage),
            let keyHelper = SignalKeyHelper(context: context) else {
            fatalError()
        }
        
        
        guard let identityKey = keyHelper.generateIdentityKeyPair() else {
            fatalError()
        }
        self.identityKey = identityKey
    }
    
    func getIdentityKeyPair() -> SignalIdentityKeyPair {
        if identityKey != nil {
            return identityKey!
        }
        let storage = SignalStorage()
        guard let context = SignalContext(storage: storage),
            let keyHelper = SignalKeyHelper(context: context) else {
            fatalError()
        }
        
        
        guard let identityKey = keyHelper.generateIdentityKeyPair() else {
            fatalError()
        }
        
        return identityKey
    }
    
    func getLocalRegistrationId() -> UInt32 {
        return registerID
    }
    
    func saveIdentity(_ address: SignalAddress, identityKey: Data?) -> Bool {
        identityKeys[address.name] = identityKey
        return true
    }
    
    func isTrustedIdentity(_ address: SignalAddress, identityKey: Data) -> Bool {
        return true
    }
}
