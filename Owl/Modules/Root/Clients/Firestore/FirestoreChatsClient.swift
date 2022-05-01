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

    static var cancellables = Set<AnyCancellable>()

    struct Collection {
        static let chats = FirebaseClient.firestore.collection("chats")
        static let chatsMessages = FirebaseClient.firestore.collection("chatsMessages")
    }

    var getChats: () -> Effect<[ChatsListPrivateItem], NSError>
    var chatWithUser: (_ uid: String) -> Effect<ChatWithUserResponse, NSError>
    var createPrivateChat: (PrivateChatCreate) -> Effect<ChatsListPrivateItem, NSError>

    var getMessages: (String) -> Effect<[Message], NSError>
    var sendMessage: (NewMessage) -> Effect<Bool, NSError>
}

// MARK: - Live

extension FirestoreChatsClient {

    // swiftlint:disable function_body_length
    static func live(userClient: UserClient) -> Self {
        return Self(
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
                                        // TODO: Add new model
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
            getMessages: { chatID in
                Effect.run { subcriber in
                    Collection.chatsMessages.document(chatID).collection("messages").order(by: "sentAt", descending: false)
                        .snapshotPublisher()
                        .on { snapshot in
                            print(snapshot)
                            let items = snapshot.documents.compactMap { document -> Message? in
                                do {
                                    return try document.data(as: Message.self)
                                } catch let error as NSError {
                                    subcriber.send(completion: .failure(error))
                                    return nil
                                }
                            }
                            subcriber.send(items)

                        }
                        error: { error in
                            subcriber.send(completion: .failure(error as NSError))
                        }
                        .sink()
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
}
