//
//  ContentView.swift
//  DemoSecureChat
//
//  Created by Sifatul Islam on 8/27/23.
//

import SwiftUI


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MessagingView()
    }
}

import SwiftUI

struct MessagingView: View {
    
    @ObservedObject private var messages: MessageArray = MessageArray.shared
    @State private var loginViewFlag: Bool = true
    @State private var messageText: String = ""
    
    @EnvironmentObject var connectManager: MessageConnectionManager
    
    var body: some View {
        if loginViewFlag {
            ZStack{
                Color.black
                VStack {
                    Button("Alice") {
                        connectManager.userSelection(for: .alice)
                        loginViewFlag = false
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    .background(Color.white)
                    
                    Button("Bob") {
                        connectManager.userSelection(for: .bob)
                        loginViewFlag = false
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    .background(Color.white)
                }
                .padding()
                .padding(.horizontal, 80)
                .background(Color.white.opacity(0.5))
            }
        } else {
            VStack {
                Label("\(connectManager.currentUser!.displayName)'s Device", image: "prfile")
                
                List(messages.messageList) { msg in
                    
                    if msg.sender != connectManager.currentUser {
                        HStack {
                            Text(msg.sender.displayName)
                            Divider()
                            Text(msg.msg)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .background(Color.cyan.opacity(0.2))
                    } else {
                        HStack {
                            Text(msg.msg)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Divider()
                            Text(msg.sender.displayName)
                        }
                        .padding(.horizontal)
                        .background(Color.mint.opacity(0.2))
                    }
                }
                .background(Color.cyan)
                Spacer()
                HStack {
                    TextField("Message Text", text: $messageText)
                    Button("Send") {
                        guard messageText.count > 0 else {
                            print("Nothing to send")
                            return
                        }
                        self.connectManager.sendMessageToOther(messageText: messageText)
                        
                        guard let user =  self.connectManager.currentUser else { return }
                        
                        MessageArray.shared.messageList.append(MessageModel(msg: messageText, sender: user))
                        messageText = ""
                    }
                }
                .padding()
            }
        }
    }
}

struct MessagingView_Previews: PreviewProvider {
    static var previews: some View {
        MessagingView()
            .environmentObject(MessageConnectionManager())
    }
}
