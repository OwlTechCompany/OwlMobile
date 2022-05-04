//
//  AuthClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import UIKit
import ComposableArchitecture
import Combine
import Firebase
import FirebaseFirestoreCombineSwift
import FirebaseAuthCombineSwift

struct AuthClient {

    var verifyPhoneNumber: (String) -> Effect<String, NSError>
    var setAPNSToken: (Data) -> Effect<Void, Never>
    var handleIfAuthNotification: (DidReceiveRemoteNotificationModel) -> Void
    var signIn: (SignIn) -> Effect<AuthDataResult, NSError>
    var signOut: () -> Void
}

// MARK: - Live

extension AuthClient {

    static func live() -> AuthClient {
        AuthClient(
            verifyPhoneNumber: verifyPhoneNumberLive,
            setAPNSToken: setAPNSTokenLive,
            handleIfAuthNotification: handleIfAuthNotification,
            signIn: signInLive,
            signOut: signOutLive
        )
    }

    static private func verifyPhoneNumberLive(
        phoneNumber: String
    ) -> Effect<String, NSError> {
        if AuthClient.testPhones.contains(phoneNumber) {
            FirebaseClient.auth.settings?.isAppVerificationDisabledForTesting = true
        }
        return FirebaseClient.phoneAuthProvider
            .verifyPhoneNumber(phoneNumber)
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static private func setAPNSTokenLive(deviceToken: Data) -> Effect<Void, Never> {
        Effect.fireAndForget {
            FirebaseClient.auth.setAPNSToken(deviceToken, type: .unknown)
        }
    }

    static private func handleIfAuthNotification(
        model: DidReceiveRemoteNotificationModel
    ) {
        if FirebaseClient.auth.canHandleNotification(model.userInfo) {
            model.completionHandler(.noData)
        }
    }

    static private func signInLive(signInModel: SignIn) -> Effect<AuthDataResult, NSError> {
        let credential = FirebaseClient.phoneAuthProvider.credential(
            withVerificationID: signInModel.verificationID,
            verificationCode: signInModel.verificationCode
        )
        return FirebaseClient.auth
            .signIn(with: credential)
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static private func signOutLive() {
        try? FirebaseClient.auth.signOut()
    }

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
