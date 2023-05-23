//
//  AuthClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import XCTestDynamicOverlay

extension AuthClient {

    static let unimplemented = Self(
        verifyPhoneNumber: XCTUnimplemented("\(Self.self).verifyPhoneNumber"),
        setAPNSToken: XCTUnimplemented("\(Self.self).setAPNSToken"),
        handleIfAuthNotification: XCTUnimplemented("\(Self.self).handleIfAuthNotification"),
        signIn: XCTUnimplemented("\(Self.self).signIn"),
        signOut: XCTUnimplemented("\(Self.self).signOut")
    )

}
