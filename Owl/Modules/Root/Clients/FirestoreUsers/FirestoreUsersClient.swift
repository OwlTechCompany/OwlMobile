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

extension DependencyValues {

    var firestoreUsersClient: FirestoreUsersClient {
        get { self[FirestoreUsersClientKey.self] }
        set { self[FirestoreUsersClientKey.self] = newValue }
    }

    enum FirestoreUsersClientKey: LiveDependencyKey {
        static var testValue = FirestoreUsersClient.unimplemented
        static let liveValue = FirestoreUsersClient.live(
            userClient: DependencyValues.current.userClient
        )
    }

}
