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
import XCTestDynamicOverlay

struct AuthClient {

    var verifyPhoneNumber: (String) -> Effect<String, NSError>
    var setAPNSToken: (Data) -> Effect<Void, Never>
    var handleIfAuthNotification: (DidReceiveRemoteNotificationModel) -> Void
    var signIn: (SignIn) -> Effect<AuthDataResult, NSError>
    var signOut: () -> Void
    
}

extension AuthClient {

    static let unimplemented = Self(
        verifyPhoneNumber: XCTUnimplemented("\(Self.self).verifyPhoneNumber"),
        setAPNSToken: XCTUnimplemented("\(Self.self).setAPNSToken"),
        handleIfAuthNotification: XCTUnimplemented("\(Self.self).handleIfAuthNotification"),
        signIn: XCTUnimplemented("\(Self.self).signIn"),
        signOut: XCTUnimplemented("\(Self.self).signOut")
    )

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

extension DependencyValues {

    var authClient: AuthClient {
        get {
            self[AuthClientKey.self]
        }
        set {
            self[AuthClientKey.self] = newValue
        }
    }

    enum AuthClientKey: DependencyKey {
        static var testValue = AuthClient.unimplemented
    }

}
