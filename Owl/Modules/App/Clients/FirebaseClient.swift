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

}

extension FirebaseClient {

    static let live: FirebaseClient = FirebaseClient(
        setup: {
            .fireAndForget {
                FirebaseApp.configure()
            }
        }
    )

}
