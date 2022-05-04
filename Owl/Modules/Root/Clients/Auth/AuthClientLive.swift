//
//  AuthClient+Live.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.05.2022.
//

import ComposableArchitecture
import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift

extension AuthClient {

    static func live() -> AuthClient {
        AuthClient(
            verifyPhoneNumber: verifyPhoneNumber,
            setAPNSToken: setAPNSToken,
            handleIfAuthNotification: handleIfAuthNotification,
            signIn: signIn,
            signOut: signOut
        )
    }
}

private extension AuthClient {

    static func verifyPhoneNumber(
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

    static func setAPNSToken(deviceToken: Data) -> Effect<Void, Never> {
        Effect.fireAndForget {
            FirebaseClient.auth.setAPNSToken(deviceToken, type: .unknown)
        }
    }

    static func handleIfAuthNotification(
        model: DidReceiveRemoteNotificationModel
    ) {
        if FirebaseClient.auth.canHandleNotification(model.userInfo) {
            model.completionHandler(.noData)
        }
    }

    static func signIn(signInModel: SignIn) -> Effect<AuthDataResult, NSError> {
        let credential = FirebaseClient.phoneAuthProvider.credential(
            withVerificationID: signInModel.verificationID,
            verificationCode: signInModel.verificationCode
        )
        return FirebaseClient.auth
            .signIn(with: credential)
            .mapError { $0 as NSError }
            .eraseToEffect()
    }

    static func signOut() {
        try? FirebaseClient.auth.signOut()
    }

}
