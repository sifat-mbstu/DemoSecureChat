//
//  DemoSignalSessionStore.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/7/23.
//

import Foundation
import SignalProtocolObjC

class DemoSignalSessionStore: NSObject, SignalSessionStore {
    var sessions = [String: Data]()
    
    override init() {
        
    }
    
    func sessionRecord(for address: SignalAddress) -> Data? {
        print("get session for \(address.name)")
        return sessions[address.name]
    }
    
    func storeSessionRecord(_ recordData: Data, for address: SignalAddress) -> Bool {
        print("store session for \(address.name)")
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

