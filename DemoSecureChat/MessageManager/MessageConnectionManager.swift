//
//  MessageConnectionManager.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/27/23.
//

import UIKit
import SignalProtocolObjC
import CocoaMQTT
import Combine

class MessageConnectionManager: ObservableObject {
    
    var currentUser: User?
    var otherUser: User?
    
    private var cryptoManager: EncryptionHelper!
    private var currentUserSessionBuilder: SignalSessionBuilder!
    
    var receivedMessageText: String = ""
    
    var subscriptions = Set<AnyCancellable>()
    
    func userSelection(for user: User) {
        
        self.currentUser = user == .alice ? .alice : .bob
        self.otherUser = user == .alice ? .bob : .alice
        
        self.setupMQTT()
        self.setupSignal()
    }
    
    func sendMessageToOther(messageText: String) {
        
        guard let otherUser, let currentUser else {return}
        guard let jsonData = try? JSONEncoder().encode(messageText) else {
            print("Error: Could not Decode payload.")
            return
        }
        guard let encryptedData = cryptoManager?.encrypt(jsonData, toAddress: otherUser.signalAddress) else {
            print("Encryption Failed")
            return
        }
        
        let base64String = encryptedData.data.base64String
        
        if cryptoManager.preKeyStore.containsPreKey(withId: cryptoManager.preKey.preKeyId) {
            print("Success: ✅✅ Should contain")
        }
        
        let payload = EncryptionPayload(signalName: currentUser.name, signalDevice:Int(currentUser.deviceId), payload: base64String, cipherType: encryptedData.cipherType)
        
        DispatchQueue.main.async { [weak self] in
            
            guard self != nil else {return}
            
            let mId = MQTTManager.shared.mqttClient.publishMessage(type: .inbox, topicUserID: otherUser.name, msg: payload)
            print("messageText: \(messageText) mId: \(String(describing: mId))")
        }
        
    }
    
    private func setupMQTT() {
        
        if let currentUser { MQTTManager.shared.setupMQTTClient(for: currentUser.name) }
        MQTTManager.shared.mqttClient.mqttDelegate = self
    }
    
    private func setupSignal() {
        
        guard let currentUser, let otherUser else {return}
        cryptoManager = EncryptionHelper(address: currentUser.signalAddress, signedPrekeyId: 150)
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            MQTTManager.shared.mqttClient.publishMessage(type: .prekey, topicUserID: otherUser.name, msg: self.cryptoManager.getPrekeyPayload())
        }
    }
}

extension MessageConnectionManager: MQTTClientDelegate {
    
    func didReceiveMessage(topic: String, mqttMessage: CocoaMQTTMessage) {
        
        let topicStrComponents = topic.components(separatedBy: "/")
        guard topicStrComponents.count > 3 else {
            return
        }
        let userId = topicStrComponents[2]
        let topicNameSuffix = topicStrComponents.suffix(from: 3).joined(separator: "/")
        
        guard let topicType = MQTTTopicType(rawValue: topicNameSuffix) else {
            print ("Invalid topic name\(topic)")
            return
        }
        
        switch topicType {
            
        case .inbox:
            guard mqttMessage.string != nil else {
                print("Message Not Found")
                return
            }
            
            let data = Data(bytes: mqttMessage.payload, count: mqttMessage.payload.count)
            guard let otherUser else {return}
            self.didReceiveMessage(sender: otherUser, data: data)
            
        case .prekey:
            let data = Data(bytes: mqttMessage.payload, count: mqttMessage.payload.count)
            guard let prekeyBundle = try? JSONDecoder().decode(EncodablePrekey.self, from: data) else {
                fatalError("Could Not Decode!!")
            }
            let actualPrekeyBundle = prekeyBundle.converToSingleBundle()
            
            guard let otherUser else {return}
            cryptoManager.createSession(for: otherUser.signalAddress, preKeyBundle: actualPrekeyBundle)
            print("Success:: \(#function) \(actualPrekeyBundle)")
        }
    }
}

extension MessageConnectionManager {
    
    private func didReceiveMessage(sender: User, data: Data) {
        
        guard let jsonPayload = try? JSONDecoder().decode(EncryptionPayload.self, from: data) else {
            return
        }
        guard let data = jsonPayload.payload.base64Data else {
            print("Error: Could not create base64 string")
            return
        }
        let cryptoPayload = EncryptedPayload(data: data, cipherType: jsonPayload.cipherType)
        guard let decryptedData = self.cryptoManager.decrypt(cryptoPayload, fromAddress: SignalAddress(name: jsonPayload.signalName, deviceId: Int32(jsonPayload.signalDevice))) else {
            return
        }
        guard let receivedMessage = try? JSONDecoder().decode(String.self, from: decryptedData) else {
            return
        }

        print("Success: \(#function): from:\(sender.displayName)")
        
        DispatchQueue.main.async {
            MessageArray.shared.messageList.append(MessageModel(msg: receivedMessage, sender: sender))
        }
    }
}
