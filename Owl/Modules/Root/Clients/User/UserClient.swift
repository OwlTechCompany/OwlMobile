//
//  UserClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import FirebaseAuthCombineSwift

struct UserClient {

    var authUser: CurrentValueSubject<Firebase.User?, Never>
    var firestoreUser: CurrentValueSubject<User?, Never>
    var setup: () -> Void
    
}
