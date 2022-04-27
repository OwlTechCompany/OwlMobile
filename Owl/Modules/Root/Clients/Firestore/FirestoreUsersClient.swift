//
//  FirestoreUsersClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Combine
import ComposableArchitecture
import FirebaseFirestoreCombineSwift
import Firebase

struct FirestoreUsersClient {

    static let collection = Firestore.firestore().collection("users")
    static var cancellables = Set<AnyCancellable>()

    var setMeIfNeeded: () -> Effect<SignInUserType, NSError>
    var updateMe: (UserUpdate) -> Effect<Bool, NSError>

    var users: (UserQuery) -> Effect<[User], NSError>
}

// MARK: - Live

extension FirestoreUsersClient {

    static func live(userClient: UserClient) -> FirestoreUsersClient {
        FirestoreUsersClient(
            setMeIfNeeded: { setMeIfNeededLive(userClient: userClient) },
            updateMe: { updateMeLive(userUpdate: $0, userClient: userClient) },
            users: usersLive
        )
    }

    static private func setMeIfNeededLive(
        userClient: UserClient
    ) -> Effect<SignInUserType, NSError> {
        Effect.future { callback in
            guard let authUser = userClient.authUser.value else {
                return callback(.failure(.init(domain: "No user", code: 1)))
            }
            let newUser = User(
                uid: authUser.uid,
                phoneNumber: authUser.phoneNumber,
                firstName: nil,
                lastName: nil,
                photo: .placeholder
            )
            let documentRef = collection.document(authUser.uid)
            documentRef.getDocument()
                .catch { error -> AnyPublisher<DocumentSnapshot, Never> in
                    callback(.failure(error as NSError))
                    return Empty(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                .flatMap { snapshot -> AnyPublisher<Void, Error> in
                    switch snapshot.exists {
                    case true:
                        callback(.success(.userExists))
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    case false:
                        return documentRef.setData(from: newUser)
                            .eraseToAnyPublisher()
                    }
                }
                .on(
                    value: { _ in callback(.success(.newUser)) },
                    error: { callback(.failure($0 as NSError)) }
                )
                .sink()
                .store(in: &cancellables)
        }
    }

    static private func updateMeLive(
        userUpdate: UserUpdate,
        userClient: UserClient
    ) -> Effect<Bool, NSError> {
        Effect.future { callback in
            guard let authUser = userClient.authUser.value else {
                return callback(.failure(.init(domain: "No user", code: 1)))
            }
            collection.document(authUser.uid).updateData(from: userUpdate)
                .on(
                    value: { callback(.success(true)) },
                    error: { callback(.failure($0 as NSError)) }
                )
                .sink()
                .store(in: &cancellables)
        }
    }

    static func usersLive(userQuery: UserQuery) -> Effect<[User], NSError> {
        Effect.future { callback in
            collection
                .whereField("phoneNumber", isEqualTo: userQuery.phoneNumber)
                .getDocuments()
                .on(
                    value: { snapshot in
                        let items = snapshot.documents.compactMap { document -> User? in
                            do {
                                return try document.data(as: User.self)
                            } catch let error as NSError {
                                callback(.failure(error))
                                return nil
                            }
                        }
                        callback(.success(items))
                    },
                    error: { callback(.failure($0 as NSError)) }
                )
                .sink()
                .store(in: &cancellables)
        }
    }
}
