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
    static let messaging = Messaging.messaging()

    var setup: () -> Void

    enum State {
        case production
        case development(host: String)
    }
}
