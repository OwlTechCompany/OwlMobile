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
    var chatWithUser: (String) -> Effect<ChatWithUserResponse, NSError>
    var createPrivateChat: (PrivateChatRequest) -> Effect<ChatsListPrivateItem, NSError>
}

// MARK: - Live

enum ChatWithUserResponse: Equatable {
    case chatItem(ChatsListPrivateItem)
    case needToCreate(withUserID: String)
}

extension FirestoreChatsClient {

    static let live = FirestoreChatsClient(
        getChats: { authUser in
            .run { subscriber in
                collection.whereField("members", arrayContains: authUser.uid)
                    .snapshotPublisher()
                    .on(
                        value: { snapshot in
                            print(snapshot)
                            let items = snapshot.documents.compactMap { document -> ChatsListPrivateItem? in
                                do {
                                    return try document.data(as: ChatsListPrivateItem.self)
                                } catch let error as NSError {
                                    subscriber.send(completion: .failure(error))
                                    return nil
                                }
                            }
                            subscriber.send(items)
                        },
                        error: { error in
                            print(error)
                            subscriber.send(completion: .failure(error as NSError))
                        }
                    )
                    .sink()
            }
        },
        chatWithUser: { userId in
            .future { result in
                let users = [userId, Auth.auth().currentUser!.uid]
                let reversed: [String] = users.reversed()
                collection
                    .whereField("members", in: [users, reversed])
//                    .whereField("members", arrayContains: userId)
//                    .whereField("members", in: [Auth.auth().currentUser!.uid])
//                    .filter(using: NSPredicate)
                    .getDocuments()
                    .on(
                        value: { snapshot in
                            if let document = snapshot.documents.first {
                                do {
                                    let chatsListPrivateItem = try document.data(as: ChatsListPrivateItem.self)
                                    result(.success(.chatItem(chatsListPrivateItem)))
                                } catch let error as NSError {
                                    result(.failure(error as NSError))
                                }
                            } else {
                                result(.success(.needToCreate(withUserID: userId)))
                            }
                        },
                        error: { result(.failure($0 as NSError)) }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        },
        createPrivateChat: { chatsListPrivateItem in
            .future { result in
                let newDocument = collection.document()
                var chatsListPrivateItem = chatsListPrivateItem
                chatsListPrivateItem.id = newDocument.documentID

                newDocument.setData(from: chatsListPrivateItem)
                    .catch { error -> AnyPublisher<Void, Never> in
                        result(.failure(error as NSError))
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
                    .flatMap { _ in newDocument.getDocument().eraseToAnyPublisher() }
                    .on(
                        value: { response in
                            do {
                                let chatsListPrivateItem = try response.data(as: ChatsListPrivateItem.self)
                                result(.success(chatsListPrivateItem))
                            } catch let error as NSError {
                                result(.failure(error as NSError))
                            }
                        },
                        error: { result(.failure($0 as NSError)) }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        }
    )
}
