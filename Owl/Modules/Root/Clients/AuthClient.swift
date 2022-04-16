//
//  AuthClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import UIKit
import ComposableArchitecture
import Firebase
import FirebaseFirestoreCombineSwift

struct AuthClient {

    static var firebaseAuth: Auth { Auth.auth() }
    static var phoneAuthProvider: PhoneAuthProvider { PhoneAuthProvider.provider() }

    var currentUser: () -> Firebase.User?

    var verifyPhoneNumber: (String) -> Effect<String, Error>
    var setAPNSToken: (Data) -> Effect<Void, Never>
    var canHandleNotification: (
        [AnyHashable: Any],
        @escaping (UIBackgroundFetchResult) -> Void
    ) -> Effect<Void, Never>

    var signIn: (SignIn) -> Effect<AuthDataResult, NSError>
    var signOut: () -> Void
}

extension AuthClient {

    static let live = AuthClient(
        currentUser: { firebaseAuth.currentUser },
        verifyPhoneNumber: { phoneNumber in
            .future { completion in
                if phoneNumber == "+380931314850" {
                    firebaseAuth.settings?.isAppVerificationDisabledForTesting = true
                }
                phoneAuthProvider
                    .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(verificationID!))
                    }
            }
        },
        setAPNSToken: { deviceToken in
            .fireAndForget {
                firebaseAuth.setAPNSToken(deviceToken, type: .unknown)
            }
        },
        canHandleNotification: { userInfo, completionHandler in
            .fireAndForget {
                if firebaseAuth.canHandleNotification(userInfo) {
                    completionHandler(.noData)
                }
            }
        },
        signIn: { signInModel in
            .future { completion in
                let credential = phoneAuthProvider.credential(
                    withVerificationID: signInModel.verificationID,
                    verificationCode: signInModel.verificationCode
                )
                firebaseAuth.signIn(with: credential) { authResult, error in
                    if let error = error {
                        completion(.failure(error as NSError))
                    } else if let authResult = authResult {
                        completion(.success(authResult))
                    } else {
                        completion(.failure(.init(domain: "", code: 1)))
                    }
                }
            }
        },
        signOut: {
            try? firebaseAuth.signOut()
        }
    )

}
