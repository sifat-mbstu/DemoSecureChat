//
//  TestIdentityKeyStore.swift
//  TestSignalSwift
//
//  Created by Rifat Monzur on 8/7/20.
//  Copyright © 2020 TigerIT Foundation. All rights reserved.
//

import Foundation
import SignalProtocolObjC

class TestIdentityKeyStore: NSObject, SignalIdentityKeyStore {
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
