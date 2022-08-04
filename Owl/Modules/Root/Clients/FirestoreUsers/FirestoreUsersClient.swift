//
//  FirestoreUsersClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Combine
import ComposableArchitecture
import FirebaseFirestoreCombineSwift
import Firebase

struct FirestoreUsersClient {

    static var collection = FirebaseClient.firestore.collection("users")

    var setMeIfNeeded: () -> Effect<SignInUserType, NSError>
    var updateMe: (UserUpdate) -> Effect<Bool, NSError>
    var users: (UserQuery) -> Effect<[User], NSError>

}
