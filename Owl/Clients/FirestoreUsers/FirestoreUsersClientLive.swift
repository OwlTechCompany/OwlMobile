//
//  FirestoreUsersClientLive.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.05.2022.
//

import Combine
import ComposableArchitecture
import FirebaseFirestoreCombineSwift
import Firebase
import XCTestDynamicOverlay

extension FirestoreUsersClient {

    static func live() -> FirestoreUsersClient {
        @Dependency(\.userClient) var userClient
        return FirestoreUsersClient(
            setMeIfNeeded: { setMeIfNeeded(userClient: userClient) },
            updateMe: { updateMe(userUpdate: $0, userClient: userClient) },
            users: users
        )
    }

}

fileprivate extension FirestoreUsersClient {

    static func setMeIfNeeded(
        userClient: UserClient
    ) -> EffectPublisher<SignInUserType, NSError> {
        guard let authUser = userClient.authUser.value else {
            return EffectPublisher(error: NSError(domain: "No user", code: 1))
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

    static func updateMe(
        userUpdate: UserUpdate,
        userClient: UserClient
    ) -> EffectPublisher<Bool, NSError> {
        guard let authUser = userClient.authUser.value else {
            return EffectPublisher(error: NSError(domain: "No user", code: 1))
        }
        return collection
            .document(authUser.uid)
            .updateData(from: userUpdate)
            .map { _ in true }
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static func users(userQuery: UserQuery) -> EffectPublisher<[User], NSError> {
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
