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

}

extension AuthClient {

    static let live = AuthClient(
        verifyPhoneNumber: { phoneNumber in
            .future { completion in
                PhoneAuthProvider.provider()
                    .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(verificationID!))
                        // Sign in using the verificationID and the code sent to the user
                        // ...
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
        }
    )

}
