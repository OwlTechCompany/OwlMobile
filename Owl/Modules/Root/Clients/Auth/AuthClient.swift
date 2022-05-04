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

    var verifyPhoneNumber: (String) -> Effect<String, NSError>
    var setAPNSToken: (Data) -> Effect<Void, Never>
    var handleIfAuthNotification: (DidReceiveRemoteNotificationModel) -> Void
    var signIn: (SignIn) -> Effect<AuthDataResult, NSError>
    var signOut: () -> Void
    
}

// MARK: - Test Phones

extension AuthClient {

    static let testPhones: [String] = [
        "+380931314850",
        "+380991111111",
        "+380992222222",
        "+380993333333",
        "+380994444444",
        "+380995555555"
    ]

}
