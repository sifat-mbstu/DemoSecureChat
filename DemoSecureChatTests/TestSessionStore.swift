
//
//  TestSessionStore.swift
//  TestSignalSwift
//
//  Created by Rifat Monzur on 8/7/20.
//  Copyright © 2020 TigerIT Foundation. All rights reserved.
//

import Foundation
import SignalProtocolObjC

class TestSessionStore: NSObject, SignalSessionStore {
    var sessions = [String: Data]()
    
    override init() {
        
    }
    
    func sessionRecord(for address: SignalAddress) -> Data? {
        return sessions[address.name]
    }
    
    func storeSessionRecord(_ recordData: Data, for address: SignalAddress) -> Bool {
        sessions[address.name] = recordData
        return true
    }
    
    func sessionRecordExists(for address: SignalAddress) -> Bool {
        return sessions[address.name] != nil
    }
    
    func deleteSessionRecord(for address: SignalAddress) -> Bool {
        return sessions.removeValue(forKey: address.name) != nil
    }
    
    func allDeviceIds(forAddressName addressName: String) -> [NSNumber] {
        return []
    }
    
    func deleteAllSessions(forAddressName addressName: String) -> Int32 {
        return 0
    }
    
}
