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

    static let collection = Firestore.firestore().collection("chats")

    var getChats: (Firebase.User) -> Effect<[ChatsListPrivateItem], NSError>
}

// MARK: - Live

extension FirestoreChatsClient {

    static let live = FirestoreChatsClient(
        getChats: { authUser in
            .run { subcriber in
                collection.whereField("members", arrayContains: authUser.uid)
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
        }
    )
}
