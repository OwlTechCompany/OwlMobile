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

    static var cancellables = Set<AnyCancellable>()

    struct Collection {
        static let chats = Firestore.firestore().collection("chats")
        static let chatsMessages = Firestore.firestore().collection("chatsMessages")
    }

    var getChats: (Firebase.User) -> Effect<[ChatsListPrivateItem], NSError>
    var getMessages: (String) -> Effect<[Message], NSError>
    var sendMessage: (NewMessage) -> Effect<Bool, NSError>
}

// MARK: - Live

extension FirestoreChatsClient {

    static let live = FirestoreChatsClient(
        getChats: { authUser in
            .run { subcriber in
                Collection.chats.whereField("members", arrayContains: authUser.uid)
                    .snapshotPublisher()
                    .on(
                        value: { snapshot in
                            print(snapshot)
                            let items = snapshot.documents.compactMap { document -> ChatsListPrivateItem? in
                                do {
                                    return try document.data(as: ChatsListPrivateItem.self)
                                } catch let error as NSError {
                                    subcriber.send(completion: .failure(error))
                                    return nil
                                }
                            }
                            subcriber.send(items)
                        },
                        error: { error in
                            print(error)
                            subcriber.send(completion: .failure(error as NSError))
                        }
                    )
                    .sink()
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
                let newDocument = Collection.chatsMessages.document(newMessage.chatId).collection("messages").document()
                var message = newMessage.message
                message.id = newDocument.documentID

                newDocument.setData(from: message)
                    .on { _ in
                        callback(.success(true))
                    }
                    error: { error in
                        callback(.failure(error as NSError))
                    }
                    .sink()
                    .store(in: &cancellables)
            }
        }
    )
}
