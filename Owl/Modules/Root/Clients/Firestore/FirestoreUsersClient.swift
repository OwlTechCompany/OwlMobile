//
//  FirestoreUsersClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Combine
import ComposableArchitecture
import Firebase
import FirebaseFirestoreCombineSwift

struct FirestoreUsersClient {

    static let collection = Firestore.firestore().collection("users")
    static var cancellables = Set<AnyCancellable>()

    var setMeIfNeeded: () -> Effect<Bool, NSError>
}

// MARK: - Live

extension FirestoreUsersClient {

    static let live = FirestoreUsersClient(
        setMeIfNeeded: {
            .future { result in
                guard let authUser = Auth.auth().currentUser else {
                    result(.failure(NSError(domain: "No current user", code: 1)))
                    return
                }
                collection.whereField("uid", isEqualTo: authUser.uid)
                    .getDocuments()
                    .catch { error -> AnyPublisher<QuerySnapshot, Never> in
                        result(.failure(error as NSError))
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
                    .flatMap { snapshot -> AnyPublisher<Void, Error> in
                        if snapshot.isEmpty {
                            let user = User(uid: authUser.uid, phoneNumber: authUser.phoneNumber)
                            return collection.document()
                                .setData(from: user, encoder: Firestore.Encoder())
                                .eraseToAnyPublisher()
                        } else {
                            result(.success(true))
                            return Empty(completeImmediately: true)
                                .eraseToAnyPublisher()
                        }
                    }
                    .catch { error -> AnyPublisher<Void, Never> in
                        result(.failure(error as NSError))
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
                    .sink { result(.success(true)) }
                    .store(in: &cancellables)
            }
        }
    )
}
