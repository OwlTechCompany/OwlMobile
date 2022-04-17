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

    var setMeIfNeeded: (Firebase.User) -> Effect<SignInUserType, NSError>
    var updateUser: (UserUpdate) -> Effect<Bool, NSError>
    var users: (UserQuery) -> Effect<[User], NSError>
}

struct UserQuery {
    var phoneNumber: String
}

// MARK: - Live

extension FirestoreUsersClient {

    static let live = FirestoreUsersClient(
        setMeIfNeeded: { authUser in
            .future { result in
                let user = User(
                    uid: authUser.uid,
                    phoneNumber: authUser.phoneNumber,
                    firstName: nil,
                    lastName: nil
                )
                let documentRef = collection.document(authUser.uid)
                documentRef.getDocument()
                    .catch { error -> AnyPublisher<DocumentSnapshot, Never> in
                        result(.failure(error as NSError))
                        return Empty(completeImmediately: true)
                            .eraseToAnyPublisher()
                    }
                    .flatMap { snapshot -> AnyPublisher<Void, Error> in
                        switch snapshot.exists {
                        case true:
                            result(.success(.userExists))
                            return Empty(completeImmediately: true)
                                .eraseToAnyPublisher()
                        case false:
                            return documentRef.setData(from: user)
                                .eraseToAnyPublisher()
                        }
                    }
                    .on(
                        value: { _ in result(.success(.newUser)) },
                        error: { error in result(.failure(error as NSError)) }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        },
        updateUser: { userUpdate in
            .future { result in
                collection.document(userUpdate.uid).updateData(from: userUpdate)
                    .on(
                        value: { result(.success(true)) },
                        error: { error in result(.failure(error as NSError)) }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        },
        users: { userQuery in
            .future { result in
                collection
                    .whereField("phoneNumber", isEqualTo: userQuery.phoneNumber)
                    .getDocuments()
                    .on(
                        value: { snapshot in
                            let items = snapshot.documents.compactMap { document -> User? in
                                do {
                                    return try document.data(as: User.self)
                                } catch let error as NSError {
                                    result(.failure(error))
                                    return nil
                                }
                            }
                            result(.success(items))
                        },
                        error: { error in
                            result(.failure(error as NSError))
                        }
                    )
                    .sink()
                    .store(in: &cancellables)
            }
        }
    )
}
