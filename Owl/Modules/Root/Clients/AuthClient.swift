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

    static var firebaseAuth: Auth { Auth.auth() }
    static var phoneAuthProvider: PhoneAuthProvider { PhoneAuthProvider.provider() }

    var verifyPhoneNumber: (String) -> Effect<String, NSError>
    var setAPNSToken: (Data) -> Void // Effect<Void, Never>
    var canHandleNotification: (DidReceiveRemoteNotificationModel) -> Void // -> Effect<Void, Never>
    var signIn: (SignIn) -> Effect<AuthDataResult, NSError>
    var signOut: () -> Void
}

// MARK: - Live

extension AuthClient {

    static let live = AuthClient(
        verifyPhoneNumber: verifyPhoneNumberLive,
        setAPNSToken: setAPNSTokenLive,
        canHandleNotification: canHandleNotificationLive,
        signIn: signInLive,
        signOut: signOutLive
    )

    static private func verifyPhoneNumberLive(phoneNumber: String) -> Effect<String, NSError> {
        if AuthClient.testPhones.contains(phoneNumber) {
            firebaseAuth.settings?.isAppVerificationDisabledForTesting = true
        }
        return phoneAuthProvider
            .verifyPhoneNumber(phoneNumber)
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static private func setAPNSTokenLive(deviceToken: Data) { // -> Effect<Void, Never> {
//        Effect.fireAndForget {
        firebaseAuth.setAPNSToken(deviceToken, type: .unknown)
        print("~~~~~ set setAPNSToken AuthClient")
//        }
    }

    static private func canHandleNotificationLive(
        model: DidReceiveRemoteNotificationModel
    ) { // -> Effect<Void, Never> {
//        Effect.fireAndForget {
            if firebaseAuth.canHandleNotification(model.userInfo) {
                model.completionHandler(.noData)
            } else {
//                model.completionHandler(.newData)
            }
//        }
    }

    static private func signInLive(signInModel: SignIn) -> Effect<AuthDataResult, NSError> {
        let credential = phoneAuthProvider.credential(
            withVerificationID: signInModel.verificationID,
            verificationCode: signInModel.verificationCode
        )
        return firebaseAuth
            .signIn(with: credential)
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static private func signOutLive() {
        try? firebaseAuth.signOut()
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
