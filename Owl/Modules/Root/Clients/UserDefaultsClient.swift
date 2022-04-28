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

// MARK: - Live

extension UserDefaultsClient {

    static func live() -> UserDefaultsClient {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        return UserDefaultsClient(
            setVerificationID: { setVerificationIDLive(verificationID: $0, defaults: defaults) },
            getVerificationID: { getVerificationIDLive(defaults: defaults) },
            setUser: { setUserLive(user: $0, defaults: defaults, encoder: encoder) },
            getUser: { getUserLive(defaults: defaults, decoder: decoder) }
        )
    }

    // MARK: - VerificationID

    static private func setVerificationIDLive(
        verificationID: String,
        defaults: UserDefaults
    ) {
        defaults.set(verificationID, forKey: Key.authVerificationID.rawValue)
    }

    static private func getVerificationIDLive(
        defaults: UserDefaults
    ) -> String {
        defaults.string(forKey: Key.authVerificationID.rawValue) ?? ""
    }

    // MARK: - User

    static private func setUserLive(
        user: User?,
        defaults: UserDefaults,
        encoder: JSONEncoder
    ) {
        if let user = user {
            guard let encoded = try? encoder.encode(user) else {
                return
            }
            defaults.set(encoded, forKey: Key.user.rawValue)

        } else {
            defaults.removeObject(forKey: Key.user.rawValue)
        }
    }

    static private func getUserLive(
        defaults: UserDefaults,
        decoder: JSONDecoder
    ) -> User? {
        guard
            let userData = defaults.object(forKey: Key.user.rawValue) as? Data,
            let user = try? decoder.decode(User.self, from: userData)
        else {
            return nil
        }
        return user
    }
}

// MARK: - Key

extension UserDefaultsClient {

    enum Key: String {
        case authVerificationID
        case user
    }

}
