//
//  UserDefaultsClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 10.04.2022.
//

import Foundation

struct UserDefaultsClient {

    var setVerificationID: (String) -> Void
    var getVerificationID: () -> (String)

    var setUser: (User?) -> Void
    var getUser: () -> User?
}

// MARK: - Key

extension UserDefaultsClient {

    enum Key: String {
        case authVerificationID
        case user
    }

}
