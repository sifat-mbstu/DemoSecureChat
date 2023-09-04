//
//  MQTTTopicType.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/21/23.
//

import Foundation
import CocoaMQTT

enum MQTTTopicType: String {
    case inbox
    case prekey
    var topic: String {
        switch self {
        case .inbox:
            return "communicator/0/%@/inbox"
        
        case .prekey:
            return "communicator/0/%@/prekey"
       
        }
    }
    
    var qos: CocoaMQTTQoS {
        switch self {
        case .prekey:
            return .qos2
        default:
            return .qos1
        }
    }
    
    var retained: Bool {
        return false
    }
    
    var duplicate: Bool {
        return false
    }
    
    var lwt: String {
        return "false"
    }
    
    func getTopic(userID: String) -> String {
        let topic = String(format: self.topic, userID)
        return topic
    }
    
}
