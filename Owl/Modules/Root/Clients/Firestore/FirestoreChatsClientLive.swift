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

extension FirestoreChatsClient {

    static func live(userClient: UserClient) -> Self {
        let openedChatId = CurrentValueSubject<String?, Never>(nil)

        return FirestoreChatsClient(
            openedChatId: openedChatId,
            getChats: { getChats(userClient: userClient) },
            chatWithUser: { uid in chatWithUser(uid, userClient: userClient) },
            createPrivateChat: createPrivateChat,
            getLastMessages: { getLastMessages(chatId: openedChatId) },
            subscribeForNewMessages: { snapshot in subscribeForNewMessages(snapshot, chatId: openedChatId) },
            getNextMessages: { snapshot in getNextMessages(snapshot, chatId: openedChatId) },
            sendMessage: sendMessage
        )
    }

}

fileprivate extension FirestoreChatsClient {

    static func getChats(userClient: UserClient) -> Effect<[ChatsListPrivateItem], NSError> {
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
    }

    static func chatWithUser(_ uid: String, userClient: UserClient) -> Effect<ChatWithUserResponse, NSError> {
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
    }

    static func createPrivateChat(_ privateChatRequest: PrivateChatCreate) -> Effect<ChatsListPrivateItem, NSError> {
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
    }

    static func getLastMessages(chatId: CurrentValueSubject<String?, Never>) -> Effect<GetLastMessagesResponse, NSError> {
        Effect.future { callback in
            guard let chatID = chatId.value else {
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

                    let items = snapshot.documents.compactMap { document -> MessageResponse? in
                        do {
                            return try document.data(as: MessageResponse.self)
                        } catch let error as NSError {
                            callback(.failure(error))
                            return nil
                        }
                    }
                    let response = GetLastMessagesResponse(
                        messageResponse: items,
                        lastDocumentSnapshot: lastDocumentSnapshot,
                        subscribeForNewMessagesSnapshot: subscribeForNewMessagesSnapshot
                    )
                    callback(.success(response))
                } error: { error in
                    callback(.failure(error as NSError))
                }
                .sink()
                .store(in: &cancellables)
        }
    }

    static func subscribeForNewMessages(
        _ snapshot: DocumentSnapshot,
        chatId: CurrentValueSubject<String?, Never>
    ) -> Effect<[MessageResponse], NSError> {
        Effect.run { subscriber in
            guard let chatID = chatId.value else {
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
    }

    static func getNextMessages(
        _ snapshot: DocumentSnapshot,
        chatId: CurrentValueSubject<String?, Never>
    ) -> Effect<GetNextMessagesResponse, NSError> {
        Effect.future { callback in
            guard let chatID = chatId.value else {
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
                    let response = GetNextMessagesResponse(
                        messageResponse: items,
                        lastDocumentSnapshot: snapshot.documents.last
                    )
                    callback(.success(response))
                }
                error: { error in
                    callback(.failure(error as NSError))
                }
                .sink()
                .store(in: &cancellables)
        }
    }

    static func sendMessage(_ request: NewMessage) -> Effect<Bool, NSError> {
        Effect.future { callback in
            let batch = FirebaseClient.firestore.batch()

            let newDocument = Collection.chatsMessages.document(request.chatId).collection("messages").document()
            var message = request.message
            message.id = newDocument.documentID

            let chat = Collection.chats.document(request.chatId)

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

}
