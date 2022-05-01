//
//  FirebaseClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import Foundation
import Firebase

struct FirebaseClient {

    var state: State

    static let auth = Auth.auth()
    static let phoneAuthProvider = PhoneAuthProvider.provider()
    static let firestore = Firestore.firestore()
    static let storage = Storage.storage()

    var setup: () -> Void

    enum State {
        case production
        case development(host: String)
    }
}

// MARK: - Live

extension FirebaseClient {

    static func live() -> FirebaseClient {
        let state = State.development(host: "192.168.31.21")

        return FirebaseClient(
            state: state,
            setup: { setup(state: state) }
        )
    }
}

fileprivate extension FirebaseClient {

    static func setup(
        state: State
    ) {
        FirebaseApp.configure()

        switch state {
        case let .development(host):
            let firestoreSettings = firestore.settings
            firestoreSettings.host = "\(host):8080"
            firestoreSettings.isPersistenceEnabled = false
            firestoreSettings.isSSLEnabled = false

            firestore.settings = firestoreSettings
            auth.useEmulator(withHost: host, port: 9099)
            storage.useEmulator(withHost: host, port: 9199)

        case .production:
            break
        }
    }

}
