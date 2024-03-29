//
//  AuthClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import ComposableArchitecture
import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift

struct AuthClient {

    var verifyPhoneNumber: (String) -> EffectPublisher<String, NSError>
    var setAPNSToken: (Data) -> EffectPublisher<Void, Never>
    var handleIfAuthNotification: (DidReceiveRemoteNotificationModel) -> Void
    var signIn: (SignIn) -> EffectPublisher<AuthDataResult, NSError>
    var signOut: () -> Void
    
}

extension DependencyValues {

    var authClient: AuthClient {
        get { self[AuthClientKey.self] }
        set { self[AuthClientKey.self] = newValue }
    }

    enum AuthClientKey: DependencyKey {
        static var testValue = AuthClient.unimplemented
        static let liveValue = AuthClient.live()
    }

}

// MARK: - Test Phones

extension AuthClient {

    static let testPhones: [String] = [
        "+380931314850",
        "+380991111111",
        "+380931111111",
        "+380992222222",
        "+380993333333",
        "+380994444444",
        "+380995555555"
    ]

}
