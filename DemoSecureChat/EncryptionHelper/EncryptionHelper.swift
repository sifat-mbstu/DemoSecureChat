//
//  EncryptionHelper.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/7/23.
//

import UIKit
import SignalProtocolObjC

struct EncryptionPayload: Codable {
    
    let signalName: String
    let signalDevice: Int
    let payload: String
    let cipherType: Int
    
    enum CodingKeys: String, CodingKey {
        case signalName
        case signalDevice
        case payload = "msg"
        case cipherType
    }
    
    var byMakingGroupIDNil: EncryptionPayload {
        return .init(signalName: signalName, signalDevice: signalDevice, payload: payload, cipherType: cipherType)
    }
}

class EncryptionHelper {
    //Key stores
    let sessionStore = DemoSignalSessionStore()
    let preKeyStore = DemoPreKeyStore()
    let signedPreKeyStore = DemoSignedPrekeyStore()
    let identityKeyStore = DemoIdentityKeyStore()
    let senderKeyStore = DemoSenderKeyStore()
    
    // Address
    let address: SignalAddress
    
    //Identity & Keys
    let registrationId: UInt32
    let signedPreKey: SignalSignedPreKey
    let identityKeyPair: SignalIdentityKeyPair
    
    var preKey: SignalPreKey!
    
    let signalStorage: SignalStorage
    let signalContext: SignalContext
    let keyHelper: SignalKeyHelper
    
    var preKeyBundle: SignalPreKeyBundle {
        return try! SignalPreKeyBundle(registrationId: registrationId,
                                       deviceId: UInt32(address.deviceId),
                                       preKeyId: preKey.preKeyId,
                                       preKeyPublic: preKey.keyPair!.publicKey,
                                       signedPreKeyId: signedPreKey.preKeyId,
                                       signedPreKeyPublic: signedPreKey.keyPair!.publicKey,
                                       signature: signedPreKey.signature,
                                       identityKey: identityKeyPair.publicKey)
    }
    
    
    init(address: SignalAddress, signedPrekeyId: UInt32) {
        
        print("Initializing encryption helper for: \(address.name)")
        signalStorage = SignalStorage(sessionStore      : sessionStore,
                                      preKeyStore       : preKeyStore,
                                      signedPreKeyStore : signedPreKeyStore,
                                      identityKeyStore  : identityKeyStore,
                                      senderKeyStore    : senderKeyStore)
        signalContext = SignalContext(storage: signalStorage)!
        keyHelper = SignalKeyHelper(context: signalContext)!
        
        registrationId = keyHelper.generateRegistrationId()
        identityKeyPair = keyHelper.generateIdentityKeyPair()!
        signedPreKey = keyHelper.generateSignedPreKey(withIdentity: identityKeyPair, signedPreKeyId: signedPrekeyId)!
        
        preKey = keyHelper.generatePreKeys(withStartingPreKeyId: 0, count: 1).first!
        
        self.address = address
        self.storePrekeys()
    }
    
    func createSession(for address: SignalAddress, preKeyBundle: SignalPreKeyBundle) {
        print("Success: create session for: \(address.name)")
        let sessionBuilder = SignalSessionBuilder(address: address, context: signalContext)
        try! sessionBuilder.processPreKeyBundle(preKeyBundle)
    }
    
    private func storePrekeys() {
        _ = signedPreKeyStore.storeSignedPreKey(signedPreKey.serializedData()!, signedPreKeyId: signedPreKey.preKeyId)
        _ = preKeyStore.storePreKey(preKey.serializedData()!, preKeyId: preKey.preKeyId)
        identityKeyStore.identityKey = identityKeyPair
    }
}

extension EncryptionHelper {
    
    func encrypt(_ data: Data, toAddress: SignalAddress) -> EncryptedPayload? {
        let sessionCipher = SignalSessionCipher(address: toAddress , context: signalContext)
        do {
            let cipherText = try sessionCipher.encryptData(data)
            print("Cipher text type: \(cipherText.type.rawValue + 1)")
            return EncryptedPayload(data: cipherText.data, cipherType: cipherText.type.rawValue + 1)
        } catch {
            print(error)
            return nil
        }
    }
    func encrypt(message: String, toAddress: SignalAddress) throws ->  SignalCiphertext {
        
        let messageData = message.data(using: .utf8)!
        
        let sessionCipher = SignalSessionCipher(address: toAddress, context: signalContext)
        let encryptedData = try sessionCipher.encryptData(messageData)
        
        return encryptedData
    }
    
    func decrypt(_ payload: EncryptedPayload, fromAddress: SignalAddress) -> Data? {
        let sessionCipher = SignalSessionCipher(address: fromAddress , context: signalContext)
        guard let type = SignalCiphertextType(rawValue: payload.cipherType - 1) else {
            return nil
        }
        do {
            
            let cipherText = SignalCiphertext(data: payload.data, type: type)
            let decryptedData = try sessionCipher.decryptCiphertext(cipherText)
            return decryptedData
        } catch {
            print("Could not decrypt message. Error: \(error)")
            return nil
        }
    }
    
    func decrypt(encryptedData: SignalCiphertext, fromAddress: SignalAddress) -> String {
        
        let sessionCipher = SignalSessionCipher(address: fromAddress, context: signalContext)
        let decryptData = try! sessionCipher.decryptCiphertext(encryptedData)
        let decryptText = String(data: decryptData, encoding: .utf8)!
        
        if preKeyStore.containsPreKey(withId: preKey.preKeyId) {
            print("Failed! Should not contain")
        }
        
        return decryptText
    }
    
    func getPrekeyPayload() ->  EncodablePrekey {
        return EncodablePrekey(from: preKeyBundle)
    }
}

struct EncryptedPayload {
    let data: Data
    let cipherType: Int
}
