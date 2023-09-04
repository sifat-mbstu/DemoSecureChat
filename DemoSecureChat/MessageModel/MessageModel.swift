//
//  MessageModel.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/27/23.
//
import SwiftUI
import Foundation
import SignalProtocolObjC

class MessageArray: ObservableObject {
    
    static let shared = MessageArray()
    @Published var messageList: [MessageModel] = []
    private init() {}
}

class MessageModel: Identifiable {
    
    let id = UUID()
    var msg: String = ""
    var sender: User = .alice
    
    init(msg: String, sender: User) {
        self.msg = msg
        self.sender = sender
    }
}
