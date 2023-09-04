//
//  DemoSenderKeyStore.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/7/23.
//

import Foundation
import SignalProtocolObjC

class DemoSenderKeyStore: NSObject, SignalSenderKeyStore {
    var senderKeys = [String: Data]()
    var senderKeysByGroupId = [String: Data]()
    
    func storeSenderKey(_ senderKey: Data, address: SignalAddress, groupId: String) -> Bool {
        senderKeys[address.name] = senderKey
        senderKeysByGroupId[groupId] = senderKey
        return true
    }
    
    func loadSenderKey(for address: SignalAddress, groupId: String) -> Data? {
        return senderKeys[address.name]
    }
    
    
}

