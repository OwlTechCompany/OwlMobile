//
//  FirebaseClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import Foundation
import Firebase

struct FirebaseClient {

    var setup: () -> Void

}

extension FirebaseClient {

    static let live: FirebaseClient = FirebaseClient(
        setup: setupLive
    )

    static func setupLive() {
//        let host = "192.168.31.30"
        FirebaseApp.configure()
        let firestoreSettings = Firestore.firestore().settings
        firestoreSettings.host = "\(host):8080"
        firestoreSettings.isPersistenceEnabled = false
        firestoreSettings.isSSLEnabled = false
        Firestore.firestore().settings = firestoreSettings
    }

}

//let host = "localhost"
let host = "192.168.31.30"
