//
//  DemoLog.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 9/4/23.
//

import Foundation

public struct DemoLog {
    
    internal static func event(_ event: DemoStates) {
        print("DemoLog: \(event.shortDescription())")
    }
    
    internal static func event(_ event: DemoStates, user: User) {
        print("DemoLog: \(event.shortDescription()) for user \(user.displayName)")
    }
    
    internal static func event(_ message: String) {
        print("DemoLog: \(message)")
    }
}
