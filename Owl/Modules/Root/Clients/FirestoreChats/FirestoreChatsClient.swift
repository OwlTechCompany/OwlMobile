//
//  FirestoreChatsClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import Combine
import ComposableArchitecture
import Firebase
import FirebaseFirestoreCombineSwift

struct FirestoreChatsClient {

    struct Collection {
        static let chats = FirebaseClient.firestore.collection("chats")
        static let chatsMessages = FirebaseClient.firestore.collection("chatsMessages")
    }

    // As we can't simply synchronise states with deep navigation
    // Let's store openedChatId here for now.
    var openedChatId: CurrentValueSubject<String?, Never>

    var getChats: () -> Effect<[ChatsListPrivateItem], NSError>
    var chatWithUser: (_ uid: String) -> Effect<ChatWithUserResponse, NSError>
    var createPrivateChat: (PrivateChatCreate) -> Effect<ChatsListPrivateItem, NSError>

    var getLastMessages: () -> Effect<GetLastMessagesResponse, NSError>
    var subscribeForNewMessages: (DocumentSnapshot) -> Effect<[MessageResponse], NSError>
    var getNextMessages: (DocumentSnapshot) -> Effect<GetNextMessagesResponse, NSError>
    var sendMessage: (NewMessage) -> Effect<Bool, NSError>
}
