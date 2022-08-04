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
import XCTestDynamicOverlay

struct FirestoreUsersClient {

    static var collection = FirebaseClient.firestore.collection("users")

    var setMeIfNeeded: () -> Effect<SignInUserType, NSError>
    var updateMe: (UserUpdate) -> Effect<Bool, NSError>
    var users: (UserQuery) -> Effect<[User], NSError>

}

extension FirestoreUsersClient {

    static let unimplemented = Self(
        setMeIfNeeded: XCTUnimplemented("\(Self.self).setMeIfNeeded"),
        updateMe: XCTUnimplemented("\(Self.self).updateMe"),
        users: XCTUnimplemented("\(Self.self).users")
    )

}

extension DependencyValues {

    var firestoreUsersClient: FirestoreUsersClient {
        get {
            self[FirestoreUsersClientKey.self]
        }
        set {
            self[FirestoreUsersClientKey.self] = newValue
        }
    }

    enum FirestoreUsersClientKey: DependencyKey {
        static var testValue = FirestoreUsersClient.unimplemented
    }

}
