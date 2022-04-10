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

}

extension UserDefaultsClient {

    static let live = UserDefaultsClient(
        setVerificationID: { verificationID in
            UserDefaults.standard.set(verificationID, forKey: Key.authVerificationID.rawValue)
        },
        getVerificationID: {
            UserDefaults.standard.string(forKey: Key.authVerificationID.rawValue) ?? ""
        }
    )

}

extension UserDefaultsClient {

    enum Key: String {
        case authVerificationID
    }

}
