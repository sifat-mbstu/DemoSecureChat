//
//  DemoSecureChatApp.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/27/23.
//

import SwiftUI

@main
struct DemoSecureChatApp: App {
    var body: some Scene {
        WindowGroup {
            MessagingView()
                .environmentObject(MessageConnectionManager())
        }
    }
}
