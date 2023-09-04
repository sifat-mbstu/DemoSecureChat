# DemoSecureChat
A basic implementation of secure chatting app using VerneMQ & Signal Protocol.

  <img src="https://github.com/sifat-mbstu/DemoSecureChat/blob/main/ReadMeImages/AliceSide.PNG" width="360px" height="800px">  <img src="https://github.com/sifat-mbstu/DemoSecureChat/blob/main/ReadMeImages/BobSide.PNG" width="360px" height="800px">
 - A demo secure chat as like the picture using swiftUI.
 - We used verneMQ as a local server to pass the messages.
 - We’ll encrypt the messages before sending and decrypt the messages after receiving using Signal Protocol.

##SignalProtocol
 - The end to end encryption process is done by [SignalProtocol-ObjC](https://github.com/ChatSecure/SignalProtocol-ObjC) library.
 - A signal session is created using this library in order to encrypt and decrypt messages.
 - <img src="https://github.com/sifat-mbstu/DemoSecureChat/blob/main/ReadMeImages/SessionCreation.png">
##MQTT
 - [Vernemq](https://github.com/vernemq/vernemq) is used locally as mqtt message broker which is a high-performance, distributed MQTT message broker.
 - [CocoaMQTT](https://github.com/emqx/CocoaMQTT) library is used to communicate with client to broker and vice versa.
 - Alice is subscribed to a topic and Bob is publish to that topic in order to pass encrypted message as like the picture.
 - <img src="https://github.com/sifat-mbstu/DemoSecureChat/blob/main/ReadMeImages/AliceBobSubscription.png">
