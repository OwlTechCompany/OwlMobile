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

    static var collection = FirebaseClient.firestore.collection("users")

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
        guard let authUser = userClient.authUser.value else {
            return Effect(error: NSError(domain: "No user", code: 1))
        }
        let newUser = User(
            uid: authUser.uid,
            phoneNumber: authUser.phoneNumber,
            firstName: nil,
            lastName: nil,
            photo: .placeholder
        )
        let documentRef = collection.document(authUser.uid)

        return documentRef.getDocument()
            .flatMap { snapshot -> AnyPublisher<SignInUserType, Error> in
                switch snapshot.exists {
                case true:
                    return Just(.userExists)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()

                case false:
                    return documentRef
                        .setData(from: newUser)
                        .map { _ -> SignInUserType in .newUser }
                        .eraseToAnyPublisher()
                }
            }
            .mapError { $0 as NSError }
            .eraseToEffect()

    }

    static private func updateMeLive(
        userUpdate: UserUpdate,
        userClient: UserClient
    ) -> Effect<Bool, NSError> {
        guard let authUser = userClient.authUser.value else {
            return Effect(error: NSError(domain: "No user", code: 1))
        }
        return collection
            .document(authUser.uid)
            .updateData(from: userUpdate)
            .map { _ in true }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static func usersLive(userQuery: UserQuery) -> Effect<[User], NSError> {
        return collection
            .whereField("phoneNumber", isEqualTo: userQuery.phoneNumber)
            .getDocuments()
            .tryMap { snapshot -> [User] in
                try snapshot.documents.map { document in
                    try document.data(as: User.self)
                }
            }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }
}
