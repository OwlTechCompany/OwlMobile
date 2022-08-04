//
//  UserDefaultsClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 10.04.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

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

extension UserDefaultsClient {

    static let unimplemented = Self(
        setVerificationID: XCTUnimplemented("\(Self.self).setVerificationID"),
        getVerificationID: XCTUnimplemented("\(Self.self).getVerificationID"),
        setUser: XCTUnimplemented("\(Self.self).setUser"),
        getUser: XCTUnimplemented("\(Self.self).getUser")
    )

}

extension DependencyValues {

    var userDefaultsClient: UserDefaultsClient {
        get {
            self[UserDefaultsKey.self]
        }
        set {
            self[UserDefaultsKey.self] = newValue
        }
    }

    enum UserDefaultsKey: DependencyKey {
        static var testValue = UserDefaultsClient.unimplemented
    }

}
