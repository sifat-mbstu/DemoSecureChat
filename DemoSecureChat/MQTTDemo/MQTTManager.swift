//
//  MQTTManager.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/27/23.
//

import Foundation

class MQTTManager {
    
    var mqttClient: MQTTClient!
    
    static var shared = MQTTManager()
    
    private init() { }
    
    func setupMQTTClient(for user: String) {
        self.mqttClient = MQTTClient(user: user)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.mqttClient.subscribe(userIDs: [user], topicTypes: [.inbox, .prekey])
        }
    }
}

