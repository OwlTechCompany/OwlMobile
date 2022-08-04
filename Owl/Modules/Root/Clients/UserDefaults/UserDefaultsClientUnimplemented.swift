//
//  UserDefaultsClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import XCTestDynamicOverlay

extension UserDefaultsClient {

    static let unimplemented = Self(
        setVerificationID: XCTUnimplemented("\(Self.self).setVerificationID"),
        getVerificationID: XCTUnimplemented("\(Self.self).getVerificationID"),
        setUser: XCTUnimplemented("\(Self.self).setUser"),
        getUser: XCTUnimplemented("\(Self.self).getUser")
    )

}
