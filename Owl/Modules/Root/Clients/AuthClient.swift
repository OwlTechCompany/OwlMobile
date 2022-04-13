//
//  AuthClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import UIKit
import FirebaseAuth
import ComposableArchitecture

struct AuthClient {

    var verifyPhoneNumber: (String) -> Effect<String, Error>
    var setAPNSToken: (Data) -> Effect<Void, Never>
    var canHandleNotification: (
        [AnyHashable: Any],
        @escaping (UIBackgroundFetchResult) -> Void
    ) -> Effect<Void, Never>
    var signIn: (SignIn) -> Effect<AuthDataResult, NSError>

}

extension AuthClient {

    static let live = AuthClient(
        verifyPhoneNumber: { phoneNumber in
            .future { completion in
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                PhoneAuthProvider.provider()
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
                let firebaseAuth = Auth.auth()
                firebaseAuth.setAPNSToken(deviceToken, type: .unknown)
            }
        },
        canHandleNotification: { userInfo, completionHandler in
            .fireAndForget {
                if Auth.auth().canHandleNotification(userInfo) {
                    completionHandler(.noData)
                }
            }
        },
        signIn: { signInModel in
            .future { completion in
                let credential = PhoneAuthProvider.provider().credential(
                    withVerificationID: signInModel.verificationID,
                    verificationCode: signInModel.verificationCode
                )
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        completion(.failure(error as NSError))
                    } else if let authResult = authResult {
                        completion(.success(authResult))
                    } else {
                        completion(.failure(.init(domain: "", code: 1)))
                    }
                }
            }
        }
    )

}
