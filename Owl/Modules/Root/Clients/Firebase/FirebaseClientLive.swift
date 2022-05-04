//
//  FirebaseClientLive.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.05.2022.
//

import Foundation
import Firebase

extension FirebaseClient {

    static func live() -> FirebaseClient {
        let state = State.production
//        let state = State.development(host: "192.168.31.26")

        return FirebaseClient(
            state: state,
            setup: { setup(state: state) }
        )
    }
}

private extension FirebaseClient {

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
