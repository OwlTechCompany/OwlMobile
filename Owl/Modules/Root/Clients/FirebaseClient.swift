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
        setup: {
            FirebaseApp.configure()
        }
    )

}
