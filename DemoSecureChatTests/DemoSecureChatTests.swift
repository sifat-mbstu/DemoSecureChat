//
//  DemoSecureChatTests.swift
//  DemoSecureChatTests
//
//  Created by Sifatul Islam on 8/27/23.
//

import XCTest
import SignalProtocolObjC
import CryptoKit
@testable import DemoSecureChat

final class DemoSecureChatTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncryption() throws {
        let aliceSessionStore = TestSessionStore()
        let alicePreKeyStore = TestPreKeyStore()
        let aliceSignedPreKeyStore = TestSignedPreKeyStore()
        let aliceIdentityKeyStore = TestIdentityKeyStore()
        let aliceSenderKeyStore = TestSenderKeyStore()
        
        let aliceStorage = SignalStorage(sessionStore: aliceSessionStore, preKeyStore: alicePreKeyStore, signedPreKeyStore: aliceSignedPreKeyStore, identityKeyStore: aliceIdentityKeyStore, senderKeyStore: aliceSenderKeyStore)
        
        guard let aliceContext = SignalContext(storage: aliceStorage),
              let aliceKeyHelper = SignalKeyHelper(context: aliceContext),
              let aliceIdentityKeyPair = aliceKeyHelper.generateIdentityKeyPair(),
              let aliceSignedPreKey = aliceKeyHelper.generateSignedPreKey(withIdentity: aliceIdentityKeyPair, signedPreKeyId: 150)
        else {
            fatalError()
        }
        
        let aliceRegistrationID = aliceKeyHelper.generateRegistrationId()
        let alicePreKeys = aliceKeyHelper.generatePreKeys(withStartingPreKeyId: 0, count: 100)
        
        let aliceAddress = SignalAddress(name: "Alice", deviceId: 101)
        let bobAddress = SignalAddress(name: "Bob", deviceId: 102)
        
        
        let bobSessionStore = TestSessionStore()
        let bobPreKeyStore = TestPreKeyStore()
        let bobSignedPreKeyStore = TestSignedPreKeyStore()
        let bobIdentityKeyStore = TestIdentityKeyStore()
        let bobSenderKeyStore = TestSenderKeyStore()
        
        let bobStorage = SignalStorage(sessionStore: bobSessionStore, preKeyStore: bobPreKeyStore, signedPreKeyStore: bobSignedPreKeyStore, identityKeyStore: bobIdentityKeyStore, senderKeyStore: bobSenderKeyStore)
        
        guard let bobContext = SignalContext(storage: bobStorage),
              let bobKeyHelper = SignalKeyHelper(context: bobContext),
              let bobIdentityKeyPair = bobKeyHelper.generateIdentityKeyPair(),
              let bobSignedPreKey = bobKeyHelper.generateSignedPreKey(withIdentity: bobIdentityKeyPair, signedPreKeyId: 151) else {
            fatalError()
        }
        
        let bobRegistrationID = bobKeyHelper.generateRegistrationId()
        let bobPreKeys = bobKeyHelper.generatePreKeys(withStartingPreKeyId: 0, count: 100)
        
        
        let selectedBobPreKey = bobPreKeys[0]
        guard let bobSelectedPrekeyPair = selectedBobPreKey.keyPair else {
            fatalError()
        }
        
        let selectedAlicePreKey = alicePreKeys[0]
        guard let aliceSelectedPrekeyPair = selectedAlicePreKey.keyPair else {
            fatalError()
        }
        
        
        let alicePreKeyBundle = try! SignalPreKeyBundle(registrationId: aliceRegistrationID, deviceId: UInt32(aliceAddress.deviceId), preKeyId: selectedAlicePreKey.preKeyId, preKeyPublic: aliceSelectedPrekeyPair.publicKey, signedPreKeyId: aliceSignedPreKey.preKeyId, signedPreKeyPublic: aliceSignedPreKey.keyPair!.publicKey, signature: aliceSignedPreKey.signature, identityKey: aliceIdentityKeyPair.publicKey)
        
        let bobPreKeyBundle = try! SignalPreKeyBundle(registrationId: bobRegistrationID, deviceId: UInt32(bobAddress.deviceId), preKeyId: selectedBobPreKey.preKeyId, preKeyPublic: bobSelectedPrekeyPair.publicKey, signedPreKeyId: bobSignedPreKey.preKeyId, signedPreKeyPublic: bobSignedPreKey.keyPair!.publicKey, signature: bobSignedPreKey.signature, identityKey: bobIdentityKeyPair.publicKey)
        
        let aliceSessionBuilder = SignalSessionBuilder(address: bobAddress, context: aliceContext)
        try! aliceSessionBuilder.processPreKeyBundle(bobPreKeyBundle)
        
        let bobSessionBuilder = SignalSessionBuilder(address: aliceAddress, context: bobContext)
        try! bobSessionBuilder.processPreKeyBundle(alicePreKeyBundle)
        
        _ = aliceSignedPreKeyStore.storeSignedPreKey(aliceSignedPreKey.serializedData()!, signedPreKeyId: aliceSignedPreKey.preKeyId)
        _ = alicePreKeyStore.storePreKey(selectedAlicePreKey.serializedData()!, preKeyId: selectedAlicePreKey.preKeyId)
        aliceIdentityKeyStore.identityKey = aliceIdentityKeyPair
        
        // Bob send to Alice
        let bobMessage = "Hi Alice"
        let bobMessageData = bobMessage.data(using: .utf8)!
        
        let bobCipher = SignalSessionCipher(address: aliceAddress, context: bobContext)
        let encryptedData = try! bobCipher.encryptData(bobMessageData)
        
        if alicePreKeyStore.containsPreKey(withId: selectedAlicePreKey.preKeyId) {
            print("Should contain")
        }
        let aliceCipher = SignalSessionCipher(address: bobAddress, context: aliceContext)
        let decryptData = try! aliceCipher.decryptCiphertext(encryptedData)
        let decryptText = String(data: decryptData, encoding: .utf8)!
        
        if alicePreKeyStore.containsPreKey(withId: selectedAlicePreKey.preKeyId) {
            print("Should not contain")
        }
        XCTAssertEqual(decryptText, bobMessage, "Decrypted text are not equal")
        
        // Bob send to Alice
        let bobMessage1 = "Hi ???"
        let bobMessageData1 = bobMessage1.data(using: .utf8)!
        let encryptedData1 = try! bobCipher.encryptData(bobMessageData1)
        let aliceCipher1 = SignalSessionCipher(address: bobAddress, context: aliceContext)
        let decryptData1 = try! aliceCipher1.decryptCiphertext(encryptedData1)
        let decryptText1 = String(data: decryptData1, encoding: .utf8)!
        XCTAssertEqual(decryptText1, bobMessage1, "Decrypted text are not equal")
        
        //Alice Send to Bob
        let aliceMessage = "Hi Bob ???"
        let aliceMessageData = aliceMessage.data(using: .utf8)!
        let aliceEncryptedData = try! aliceCipher.encryptData(aliceMessageData)
        let bobCipherNew = SignalSessionCipher(address: aliceAddress, context: bobContext)
        let aliceDecryptData1 = try! bobCipherNew.decryptCiphertext(aliceEncryptedData)
        let aliceDecryptedText = String(data: aliceDecryptData1, encoding: .utf8)!
        XCTAssertEqual(decryptText1, bobMessage1, "Decrypted text are not equal")
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
