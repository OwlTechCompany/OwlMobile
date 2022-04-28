//
//  UserClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import Foundation
import ComposableArchitecture
import Combine
import Firebase
import FirebaseFirestoreCombineSwift
import FirebaseAuthCombineSwift

struct UserClient {

    var authUser: CurrentValueSubject<Firebase.User?, Never>
    var firestoreUser: CurrentValueSubject<User?, Never>

    var setup: () -> Void
}

extension UserClient {

    static func live(userDefaults: UserDefaultsClient) -> Self {
        var liveCancellables: Set<AnyCancellable> = []
        let authUser = CurrentValueSubject<Firebase.User?, Never>(nil)
        let firestoreUser = CurrentValueSubject<User?, Never>(userDefaults.getUser())
        var userCancellable: Cancellable?
        return Self(
            authUser: authUser,
            firestoreUser: firestoreUser,
            setup: {
                // Set current user immediately
                authUser.send(Auth.auth().currentUser)

                // Subscribe for updates
                Auth.auth().authStateDidChangePublisher()
                    .sink { user in
                        authUser.send(user)

                        // If Firebase.User changes we need to update firestoreUser
                        userCancellable?.cancel()
                        if let user = user {
                            userCancellable = Firestore.firestore().collection("users")
                                .document(user.uid)
                                .snapshotPublisher()
                                .map { try? $0.data(as: User.self) }
                                .on(value: {
                                    userDefaults.setUser($0)
                                    firestoreUser.send($0)
                                })
                                .sink()
                        } else {
                            userDefaults.setUser(nil)
                            firestoreUser.send(nil)
                        }
                    }
                    .store(in: &liveCancellables)
            }
        )
    }
}
