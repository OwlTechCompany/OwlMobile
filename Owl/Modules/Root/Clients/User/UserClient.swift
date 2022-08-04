//
//  UserClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import FirebaseAuthCombineSwift
import XCTestDynamicOverlay
import ComposableArchitecture

struct UserClient {

    var authUser: CurrentValueSubject<Firebase.User?, Never>
    var firestoreUser: CurrentValueSubject<User?, Never>
    var setup: () -> Void
    
}

extension UserClient {

    static let unimplemented = Self(
        authUser: CurrentValueSubject(nil),
        firestoreUser: CurrentValueSubject(nil),
        setup: XCTUnimplemented("\(Self.self).setup")
    )

}

extension DependencyValues {

    var userClient: UserClient {
        get {
            self[UserClientKey.self]
        }
        set {
            self[UserClientKey.self] = newValue
        }
    }

    enum UserClientKey: DependencyKey {
        static var testValue = UserClient.unimplemented
    }

}
