//
//  FirebaseClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import Foundation
import Firebase
import ComposableArchitecture

struct FirebaseClient {

    var setup: () -> Effect<Never, Never>

    var verifyPhoneNumber: (String) -> Effect<String, Error>
}

extension FirebaseClient {

    static let live: FirebaseClient = FirebaseClient(
        setup: {
            .fireAndForget {
                FirebaseApp.configure()
            }
        },
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
        }
    )

}
