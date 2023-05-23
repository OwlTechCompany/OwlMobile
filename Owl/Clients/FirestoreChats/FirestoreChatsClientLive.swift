//
//  FirestoreChatsClientLive.swift
//  Owl
//
//  Created by Anastasia Holovash on 05.08.2022.
//

import Combine
import ComposableArchitecture
import Firebase
import FirebaseFirestoreCombineSwift
import Foundation

enum FirestoreChatsClientError: Error {
    case standard
}

extension FirestoreChatsClient {
    
    static func live() -> Self {
        let openedChatId = CurrentValueSubject<String?, Never>(nil)
        @Dependency(\.userClient) var userClient
        return FirestoreChatsClient(
            openedChatId: openedChatId,
            getChats: { getChats(userClient: userClient) },
            chatWithUser: { uid in chatWithUser(uid, userClient: userClient) },
            createPrivateChat: createPrivateChat,
            getLastMessages: { getLastMessages(chatId: openedChatId) },
            subscribeForNewMessages: { snapshot in subscribeForNewMessages(snapshot, chatId: openedChatId) },
            getPaginatedMessages: { snapshot in getPaginatedMessages(snapshot, chatId: openedChatId) },
            sendMessage: sendMessage
        )
    }
    
}

fileprivate extension FirestoreChatsClient {
    
    static func getChats(userClient: UserClient) -> EffectPublisher<[ChatsListPrivateItem], NSError> {
        guard let authUser = userClient.authUser.value else {
            return EffectPublisher(error: NSError())
        }
        return Collection.chats
            .whereField("membersIDs", arrayContains: authUser.uid)
            .order(by: "updatedAt", descending: true)
            .snapshotPublisher()
            .tryMap { snapshot in
                try snapshot.documents.compactMap { document in
                    try document.data(as: ChatsListPrivateItem.self)
                }
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
    
    static func chatWithUser(_ uid: String, userClient: UserClient) -> EffectPublisher<ChatWithUserResponse, NSError> {
        guard let authUser = userClient.authUser.value else {
            return EffectPublisher(error: NSError())
        }
        let users = [uid, authUser.uid]
        let usersReversed: [String] = users.reversed()
        
        return Collection.chats
            .whereField("membersIDs", in: [users, usersReversed])
            .getDocuments()
            .tryMap { snapshot -> ChatWithUserResponse in
                if let document = snapshot.documents.first {
                    let chatsListPrivateItem = try document.data(as: ChatsListPrivateItem.self)
                    return .chatItem(chatsListPrivateItem)
                } else {
                    return .needToCreate(withUserID: uid)
                }
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
    
    static func createPrivateChat(_ privateChatRequest: PrivateChatCreate) -> EffectPublisher<ChatsListPrivateItem, NSError> {
        let newDocument = Collection.chats.document()
        
        // Update id of PrivateChatRequest
        var privateChatRequest = privateChatRequest
        privateChatRequest.id = newDocument.documentID
        
        return newDocument.setData(from: privateChatRequest)
            .flatMap { _ in newDocument.getDocument().eraseToAnyPublisher() }
            .tryMap { response in
                try response.data(as: ChatsListPrivateItem.self)
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
    
    static func getLastMessages(chatId: CurrentValueSubject<String?, Never>) -> EffectPublisher<GetLastMessagesResponse, NSError> {
        guard let chatID = chatId.value else {
            return EffectPublisher(error: NSError())
        }
        
        return Collection.chatsMessages.document(chatID).collection("messages")
            .order(by: "sentAt", descending: true)
            .limit(to: 25)
            .getDocuments()
            .tryMap { snapshot -> GetLastMessagesResponse in
                guard
                    let lastDocumentSnapshot = snapshot.documents.last,
                    let subscribeForNewMessagesSnapshot = snapshot.documents.first
                else {
                    throw FirestoreChatsClientError.standard
                }
                
                let items = try snapshot.documents.compactMap { document -> MessageResponse? in
                    try document.data(as: MessageResponse.self)
                }
                
                return GetLastMessagesResponse(
                    messageResponse: items,
                    lastDocumentSnapshot: lastDocumentSnapshot,
                    subscribeForNewMessagesSnapshot: subscribeForNewMessagesSnapshot
                )
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
        
    }
    
    static func subscribeForNewMessages(
        _ snapshot: DocumentSnapshot,
        chatId: CurrentValueSubject<String?, Never>
    ) -> EffectPublisher<[MessageResponse], NSError> {
        guard let chatID = chatId.value else {
            return EffectPublisher(error: NSError())
        }
        
        return Collection.chatsMessages.document(chatID).collection("messages")
            .order(by: "sentAt", descending: true)
            .end(beforeDocument: snapshot)
            .snapshotPublisher()
            .tryMap { snapshot -> [MessageResponse] in
                try snapshot.documents.compactMap { document -> MessageResponse? in
                    try document.data(as: MessageResponse.self)
                }
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
    
    static func getPaginatedMessages(
        _ snapshot: DocumentSnapshot,
        chatId: CurrentValueSubject<String?, Never>
    ) -> EffectPublisher<GetPaginatedMessagesResponse, NSError> {
        guard let chatID = chatId.value else {
            return EffectPublisher(error: NSError())
        }
        
        return Collection.chatsMessages.document(chatID).collection("messages")
            .order(by: "sentAt", descending: true)
            .start(afterDocument: snapshot)
            .limit(to: 25)
            .getDocuments()
            .tryMap { snapshot -> GetPaginatedMessagesResponse in
                let items = try snapshot.documents.map { document in
                    try document.data(as: MessageResponse.self)
                }
                return GetPaginatedMessagesResponse(
                    messageResponse: items,
                    lastDocumentSnapshot: snapshot.documents.last
                )
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
    
    static func sendMessage(_ request: NewMessage) -> EffectPublisher<Bool, NSError> {
        let batch = FirebaseClient.firestore.batch()
        
        let newDocument = Collection.chatsMessages.document(request.chatId).collection("messages").document()
        var message = request.message
        message.id = newDocument.documentID
        
        let chat = Collection.chats.document(request.chatId)
        
        do {
            try batch.setData(from: message, forDocument: newDocument)
            let encodedMessage = try Firestore.Encoder().encode(message)
            batch.updateData(
                [
                    "lastMessage": encodedMessage,
                    "updatedAt": FieldValue.serverTimestamp()
                ],
                forDocument: chat
            )
            
            return batch.commit()
                .map { _ in true }
                .mapError { $0 as NSError }
                .eraseToEffect()
        } catch {
            return EffectPublisher(error: NSError())
        }
    }
    
}
