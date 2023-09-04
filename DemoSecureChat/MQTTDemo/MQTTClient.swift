//
//  MQTTClient.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/20/23.
//

import UIKit
import CocoaMQTT
import CocoaLumberjack
import Starscream
import SignalProtocolObjC

protocol MQTTClientDelegate: AnyObject{
    func didReceiveMessage( topic: String, mqttMessage: CocoaMQTTMessage)
}

class MQTTClient {
    
    let mqtt: CocoaMQTT
    weak var mqttDelegate: MQTTClientDelegate?
    var currentUser: String!
    init(user: String) {

        let clientID = "CocoaMQTT-" + user
        mqtt = CocoaMQTT(clientID: clientID, host: "192.168.205.94", port: 1883)
        mqtt.keepAlive = 600
        mqtt.delegate = self
        mqtt.backgroundOnSocket = false
        mqtt.logLevel = .debug
        currentUser = user
        self.connect()
        
    }
    
    func connect(){
        let isSucceed = mqtt.connect(timeout: 15)
        DemoLog.event(.mqttConnectRequestSent(from: currentUser))
    }
    
    private func reconnectAfterDelay() {
        DDLogDebug(#function)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            [weak self] in
            guard let weakSelf = self else {return}
            weakSelf.connect()
        }
    }
    
    func unsubscribeAll() {
        let subs = mqtt.subscriptions
        for sub in subs {
            mqtt.unsubscribe(sub.key)
        }
    }
    func unsubscribeAllTopicsIfRequired(error: Error?){
        guard let socketError = error as? Starscream.WSError else {
            return
        }
        
        switch socketError.type {
        case .protocolError:
            DispatchQueue.main.async {
                [weak self] in
                guard let weakSelf = self else {return}
                weakSelf.unsubscribeAll()
            }
        default:
            break
        }
    }
}

extension MQTTClient: CocoaMQTTDelegate {
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        DDLogDebug(" \(#function) mqttDidPing id: \(mqtt.clientID) ")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        DDLogDebug("\(#function) mqttDidReceivePong id: \(mqtt.clientID) ")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        
        DDLogDebug(" \(#function) MQTT disconnected: \(mqtt.clientID). error: \(String(describing: err)) ")
        unsubscribeAllTopicsIfRequired(error: err)
        reconnectAfterDelay()
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DDLogDebug("Did connect ack: \(ack.description). id: \(mqtt.clientID) proc: \(#function)")
        subscribe(userIDs: [currentUser], topicTypes: [.inbox, .prekey])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        #if ENABLE_LOGGER
        let data = Data(bytes: message.payload, count: message.payload.count)
        if let debugMessage = try? customJSONDecoder.decode(DebugMessage.self, from: data) {
            DDLogDebug("mID: \(debugMessage.mID ?? ""), id: \(id), topic: \(message.topic)")
        }
        #endif
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        DDLogDebug("Did publish ack. id: \(id)")
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishComplete id: UInt16) {
        DDLogDebug("Did publish complete id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("MQTT: \(message.string) receive to topic:\(message.topic) qos: \(message.qos.description) ")
        self.mqttDelegate?.didReceiveMessage(topic: message.topic, mqttMessage: message)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        DDLogDebug("Did subscribe topic count: \(success.count) failure: \(failed.joined(separator: ","))")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        DDLogDebug("Did unsubscribe \(topics.joined(separator: ","))")
    }
}

extension MQTTClient {
    func subscribe(userIDs: [String], topicTypes: [MQTTTopicType]) {
        var subscribeTopic = [(String, CocoaMQTTQoS)]()
        for ID in userIDs {
            for type in topicTypes {
                subscribeTopic.append((type.getTopic(userID: ID), type.qos ) )
                print("MQTT: \(ID) subscribe to \(type.getTopic(userID: ID)) qos: \(type.qos.rawValue)")
            }
        }
        
        guard subscribeTopic.count > 0 else { return }
        
        DDLogDebug(subscribeTopic.map({$0.0}))
        mqtt.subscribe(subscribeTopic)
    }
}

extension MQTTClient {
    
    @discardableResult
    func publishMessage<T>(type: MQTTTopicType, topicUserID: String, msg: T) -> Int? where T : Encodable  {
        guard let data = try? JSONEncoder().encode(msg) else {
            DDLogDebug("Can't encode message. Ignoring.")
            return nil
        }

        let payload : [UInt8] = data.map { UInt8($0) }
        
        let topic = String(format: type.topic, topicUserID)
        let message = CocoaMQTTMessage(topic: topic, payload: payload, qos: type.qos, retained: type.retained)
        let msgId = mqtt.publish(message)
        print("MQTT: publish to \(topic) qos: \(type.qos.rawValue) topic: \(message.topic)")
        return msgId
    }
    
}

extension MQTTClient {
    private func showAlert(_ text: String) {
        let alert = UIAlertController(title: "\(text)", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIApplication.getTopViewController()?.present(alert, animated: true, completion: nil)
        }
    }
}

struct DebugMessage: Codable {
    let mID: String?
    let senderID: String?
    
    enum CodingKeys: String, CodingKey {
        case senderID = "from"
        case mID = "messageId"
    }
}


