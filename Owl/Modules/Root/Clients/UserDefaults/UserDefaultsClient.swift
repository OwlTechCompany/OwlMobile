//
//  UserDefaultsClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 10.04.2022.
//

import Foundation
import ComposableArchitecture

// TODO: Use userDefaults from KPIHub
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

extension DependencyValues {

    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsKey.self] }
        set { self[UserDefaultsKey.self] = newValue }
    }

    enum UserDefaultsKey: LiveDependencyKey {
        static var testValue = UserDefaultsClient.unimplemented
        static let liveValue = UserDefaultsClient.live()
    }
    
}
