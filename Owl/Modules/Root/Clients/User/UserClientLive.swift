//
//  UserClientLive.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.05.2022.
//

import ComposableArchitecture
import Combine
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import FirebaseAuthCombineSwift

extension UserClient {

    static func live(userDefaults: UserDefaultsClient) -> Self {
        let authUser = CurrentValueSubject<Firebase.User?, Never>(nil)
        let firestoreUser = CurrentValueSubject<User?, Never>(userDefaults.getUser())
        var authCancellables = Set<AnyCancellable>()
        var userCancellable: Cancellable?
        return Self(
            authUser: authUser,
            firestoreUser: firestoreUser,
            setup: {
                // Set current user immediately
                authUser.send(FirebaseClient.auth.currentUser)

                // Subscribe for updates
                FirebaseClient.auth.authStateDidChangePublisher()
                    .sink { user in
                        authUser.send(user)

                        // If Firebase.User changes we need to update firestoreUser
                        userCancellable?.cancel()
                        if let user = user {
                            userCancellable = FirebaseClient.firestore.collection("users")
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
                    .store(in: &authCancellables)
            }
        )
    }
}
