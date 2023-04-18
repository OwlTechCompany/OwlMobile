//
//  UserClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import Foundation
import Combine
import Firebase
import ComposableArchitecture

struct UserClient {

    var authUser: CurrentValueSubject<Firebase.User?, Never>
    var firestoreUser: CurrentValueSubject<User?, Never>
    var setup: () -> Void
    
}

extension DependencyValues {

    var userClient: UserClient {
        get { self[UserClientKey.self] }
        set { self[UserClientKey.self] = newValue }
    }

    enum UserClientKey: DependencyKey {
        static var testValue = UserClient.unimplemented
        static let liveValue = UserClient.live()
    }

}
