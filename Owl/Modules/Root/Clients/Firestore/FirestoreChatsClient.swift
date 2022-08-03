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
import FirebaseAuth

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

    var getLastMessages: () -> Effect<[MessageResponse], NSError>
    var subscribeForNewMessages: () -> Effect<[MessageResponse], NSError>
    var getNextMessages: () -> Effect<[MessageResponse], NSError>
    var sendMessage: (NewMessage) -> Effect<Bool, NSError>
}

// MARK: - Live

extension FirestoreChatsClient {

    // swiftlint:disable function_body_length
    static func live(userClient: UserClient) -> Self {
        let variables = Variables()
        return Self(
            openedChatId: CurrentValueSubject(nil),
            getChats: {
                Effect.run { subscriber in
                    guard let authUser = userClient.authUser.value else {
                        subscriber.send(completion: .failure(.init(domain: "No user", code: 1)))
                        return Empty<Any, NSError>(completeImmediately: true)
                            .sink()
                    }
                    return Collection.chats.whereField("members", arrayContains: authUser.uid)
                        .snapshotPublisher()
                        .on(
                            value: { snapshot in
                                subscriber.send(
                                    snapshot.documents.compactMap { document in
                                        do {
                                            return try document.data(as: ChatsListPrivateItem.self)
                                        } catch let error as NSError {
                                            subscriber.send(completion: .failure(error))
                                            return nil
                                        }
                                    }
                                )
                            },
                            error: { subscriber.send(completion: .failure($0 as NSError)) }
                        )
                        .sink()
                }
            },
            chatWithUser: { uid in
                Effect.future { callback in
                    guard let authUser = userClient.authUser.value else {
                        return callback(.failure(.init(domain: "No user", code: 1)))
                    }
                    let users = [uid, authUser.uid]
                    let usersReversed: [String] = users.reversed()
                    Collection.chats
                        .whereField("members", in: [users, usersReversed])
                        .getDocuments()
                        .on(
                            value: { snapshot in
                                if let document = snapshot.documents.first {
                                    do {
                                        let chatsListPrivateItem = try document.data(as: ChatsListPrivateItem.self)
                                        callback(.success(.chatItem(chatsListPrivateItem)))
                                    } catch let error as NSError {
                                        callback(.failure(error as NSError))
                                    }
                                } else {
                                    callback(.success(.needToCreate(withUserID: uid)))
                                }
                            },
                            error: { callback(.failure($0 as NSError)) }
                        )
                        .sink()
                        .store(in: &cancellables)
                }
            },
            createPrivateChat: { privateChatRequest in
                Effect.future { callback in
                    let newDocument = Collection.chats.document()

                    // Update id of PrivateChatRequest
                    var privateChatRequest = privateChatRequest
                    privateChatRequest.id = newDocument.documentID

                    newDocument.setData(from: privateChatRequest)
                        .catch { error -> AnyPublisher<Void, Never> in
                            callback(.failure(error as NSError))
                            return Empty(completeImmediately: true)
                                .eraseToAnyPublisher()
                        }
                        .flatMap { _ in newDocument.getDocument().eraseToAnyPublisher() }
                        .on(
                            value: { response in
                                do {
                                    let chatsListPrivateItem = try response.data(as: ChatsListPrivateItem.self)
                                    callback(.success(chatsListPrivateItem))
                                } catch let error as NSError {
                                    callback(.failure(error as NSError))
                                }
                            },
                            error: { callback(.failure($0 as NSError)) }
                        )
                        .sink()
                        .store(in: &cancellables)
                }
            },
            getLastMessages: {
                Effect.future { callback in
                    guard let chatID = variables.openedChatId else {
                        return
                    }

                    Collection.chatsMessages.document(chatID).collection("messages")
                        .order(by: "sentAt", descending: true)
                        .limit(to: 25)
                        .getDocuments()
                        .on { snapshot in
                            guard
                                let lastDocumentSnapshot = snapshot.documents.last,
                                let subscribeForNewMessagesSnapshot = snapshot.documents.first
                            else {
                                return
                            }
                            variables.lastDocumentSnapshot = lastDocumentSnapshot
                            variables.subscribeForNewMessagesSnapshot = subscribeForNewMessagesSnapshot

                            let items = snapshot.documents.compactMap { document -> MessageResponse? in
                                do {
                                    return try document.data(as: MessageResponse.self)
                                } catch let error as NSError {
                                    callback(.failure(error))
                                    return nil
                                }
                            }
                            callback(.success(items))
                        } error: { error in
                            callback(.failure(error as NSError))
                        }
                        .sink()
                        .store(in: &cancellables)
                }
            },
            subscribeForNewMessages: {
                Effect.run { subscriber in
                    guard
                        let chatID = variables.openedChatId,
                        let snapshot = variables.subscribeForNewMessagesSnapshot
                    else {
                        return Empty<Any, NSError>(completeImmediately: true)
                            .sink()
                    }

                    return Collection.chatsMessages.document(chatID).collection("messages")
                        .order(by: "sentAt", descending: true)
                        .end(beforeDocument: snapshot)
                        .snapshotPublisher()
                        .on { snapshot in
                            let items = snapshot.documents.compactMap { document -> MessageResponse? in
                                do {
                                    return try document.data(as: MessageResponse.self)
                                } catch let error as NSError {
                                    subscriber.send(completion: .failure(error))
                                    return nil
                                }
                            }
                            subscriber.send(items)
                        }
                        error: { error in
                            subscriber.send(completion: .failure(error as NSError))
                        }
                        .sink()
                }
            },
            getNextMessages: {
                Effect.future { callback in
                    guard
                        let chatID = variables.openedChatId,
                        let snapshot = variables.lastDocumentSnapshot
                    else {
                        return
                    }

                    Collection.chatsMessages.document(chatID).collection("messages")
                        .order(by: "sentAt", descending: true)
                        .start(afterDocument: snapshot)
                        .limit(to: 25)
                        .getDocuments()
                        .on { snapshot in
                            let items = snapshot.documents.compactMap { document -> MessageResponse? in
                                do {
                                    return try document.data(as: MessageResponse.self)
                                } catch let error as NSError {
                                    callback(.failure(error))
                                    return nil
                                }
                            }
                            callback(.success(items))
                            variables.lastDocumentSnapshot = snapshot.documents.last
                        }
                        error: { error in
                            callback(.failure(error as NSError))
                        }
                        .sink()
                        .store(in: &cancellables)
                }
            },
            sendMessage: { newMessage in
                Effect.future { callback in
                    let batch = FirebaseClient.firestore.batch()

                    let newDocument = Collection.chatsMessages.document(newMessage.chatId).collection("messages").document()
                    var message = newMessage.message
                    message.id = newDocument.documentID

                    let chat = Collection.chats.document(newMessage.chatId)

                    do {
                        try batch.setData(from: message, forDocument: newDocument)
                        let encodedMessage = try Firestore.Encoder().encode(message)
                        batch.updateData(["lastMessage": encodedMessage], forDocument: chat)

                        batch.commit()
                            .on { _ in
                                callback(.success(true))
                            }
                            error: { error in
                                callback(.failure(error as NSError))
                            }
                            .sink()
                            .store(in: &cancellables)

                    } catch {
                        callback(.failure(error as NSError))
                    }
                }
            }
        )
    }

    static func messages(query: Query) {

    }
}


extension FirestoreChatsClient {

    class Variables {
        var openedChatId: String?
        var lastDocumentSnapshot: DocumentSnapshot?
        var subscribeForNewMessagesSnapshot: DocumentSnapshot?

        internal init(
            openedChatId: String? = nil,
            lastDocumentSnapshot: DocumentSnapshot? = nil
        ) {
            self.openedChatId = openedChatId
            self.lastDocumentSnapshot = lastDocumentSnapshot
        }
    }

}
