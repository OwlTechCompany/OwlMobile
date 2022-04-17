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

    static let collection = Firestore.firestore().collection("chats")
    static var cancellables = Set<AnyCancellable>()

    var getChats: (Firebase.User) -> Effect<[ChatsListPrivateItem], NSError>
    var chatWithUser: (_ uid: String) -> Effect<ChatWithUserResponse, NSError>
    var createPrivateChat: (PrivateChatCreate) -> Effect<ChatsListPrivateItem, NSError>
}

// MARK: - Live

extension FirestoreChatsClient {

    // swiftlint:disable function_body_length
    static func live(userClient: UserClient) -> Self {
        return Self(
            getChats: { authUser in
                Effect.run { subscriber in
                    collection.whereField("members", arrayContains: authUser.uid)
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
                    guard let firebaseUser = userClient.firebaseUser.value?.uid else {
                        return callback(.failure(.init(domain: "No user", code: 1)))
                    }
                    let users = [uid, firebaseUser]
                    let usersReversed: [String] = users.reversed()
                    collection
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
                    let newDocument = collection.document()

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
        )
    }

}
