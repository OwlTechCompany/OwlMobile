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

    var getChats: () -> EffectPublisher<[ChatsListPrivateItem], NSError>
    var chatWithUser: (_ uid: String) -> EffectPublisher<ChatWithUserResponse, NSError>
    var createPrivateChat: (PrivateChatCreate) -> EffectPublisher<ChatsListPrivateItem, NSError>

    var getLastMessages: () -> EffectPublisher<GetLastMessagesResponse, NSError>
    var subscribeForNewMessages: (DocumentSnapshot) -> EffectPublisher<[MessageResponse], NSError>
    var getPaginatedMessages: (DocumentSnapshot) -> EffectPublisher<GetPaginatedMessagesResponse, NSError>
    var sendMessage: (NewMessage) -> EffectPublisher<Bool, NSError>
}

extension DependencyValues {

    var firestoreChatsClient: FirestoreChatsClient {
        get { self[FirestoreChatsClientKey.self] }
        set { self[FirestoreChatsClientKey.self] = newValue }
    }

    enum FirestoreChatsClientKey: DependencyKey {
        static var testValue = FirestoreChatsClient.unimplemented
        static var liveValue = FirestoreChatsClient.live()
    }

}
