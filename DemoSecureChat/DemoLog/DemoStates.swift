//
//  DemoStates.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 9/4/23.
//

import Foundation

/// Informational logging notifications issued by SecureChat
enum DemoStates {
    
    case mqttConnectRequestSent(from: String)
    case receiveMessage(from: String)
    
    /// A short description of the notification.
    /// - Returns: Returns a short description of the notification.
    public func shortDescription() -> String {
        switch self {
            
        case .mqttConnectRequestSent(from: let user):    return "\(user) send connect request through mqtt."
        
        case .receiveMessage(from: let user):   return "Receive message from \(user)"
        }
    }
}
