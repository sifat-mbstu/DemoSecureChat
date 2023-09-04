//
//  TestSenderKeyStore.swift
//  TestSignalSwift
//
//  Created by Rifat Monzur on 8/7/20.
//  Copyright © 2020 TigerIT Foundation. All rights reserved.
//

import Foundation
import SignalProtocolObjC

class TestSenderKeyStore: NSObject, SignalSenderKeyStore {
    var senderKeys = [String: Data]()
    var senderKeysByGroupId = [String: Data]()
    
    func storeSenderKey(_ senderKey: Data, address: SignalAddress, groupId: String) -> Bool {
        senderKeys[address.name] = senderKey
        senderKeysByGroupId[groupId] = senderKey
        return true
    }
    
    func loadSenderKey(for address: SignalAddress, groupId: String) -> Data? {
//        guard senderKeysByGroupId[groupId] == senderKeys[address] else {
//            return nil
//        }
//
        return senderKeys[address.name]
    }
    
    
}
