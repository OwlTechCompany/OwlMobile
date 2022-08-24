//
//  FirebaseClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import Foundation
import Firebase
import FirebaseStorage
import ComposableArchitecture

struct FirebaseClient {

    // Make not static?
    static let auth = Auth.auth()
    static let phoneAuthProvider = PhoneAuthProvider.provider()
    static let firestore = Firestore.firestore()
    static let storage = Storage.storage()
    static let messaging = Messaging.messaging()

    var state: State
    var setup: () -> Void

    enum State {
        case production
        case development(host: String)
    }
    
}

extension DependencyValues {

    var firebaseClient: FirebaseClient {
        get { self[FirebaseClientKey.self] }
        set { self[FirebaseClientKey.self] = newValue }
    }

    enum FirebaseClientKey: DependencyKey {
        static var testValue = FirebaseClient.unimplemented
        static let liveValue = FirebaseClient.live()
    }

}
