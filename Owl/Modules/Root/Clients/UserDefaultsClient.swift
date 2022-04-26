//
//  UserDefaultsClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 10.04.2022.
//

import Foundation

struct UserDefaultsClient {

    static let defaults = UserDefaults.standard
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    var setVerificationID: (String) -> Void
    var getVerificationID: () -> (String)

    var setUser: (User?) -> Void
    var getUser: () -> User?
}

extension UserDefaultsClient {

    static let live = UserDefaultsClient(
        setVerificationID: { verificationID in
            defaults.set(verificationID, forKey: Key.authVerificationID.rawValue)
        },
        getVerificationID: {
            defaults.string(forKey: Key.authVerificationID.rawValue) ?? ""
        },
        setUser: { user in
            if let user = user {
                guard let encoded = try? encoder.encode(user) else {
                    return
                }
                defaults.set(encoded, forKey: Key.user.rawValue)

            } else {
                defaults.removeObject(forKey: Key.user.rawValue)
            }
        },
        getUser: {
            guard
                let userData = defaults.object(forKey: Key.user.rawValue) as? Data,
                let user = try? decoder.decode(User.self, from: userData)
            else {
                return nil
            }
            return user
        }
    )

}

extension UserDefaultsClient {

    enum Key: String {
        case authVerificationID
        case user
    }

}
