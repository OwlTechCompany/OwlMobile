//
//  FirestoreUsersClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import XCTestDynamicOverlay

extension FirestoreUsersClient {

    static let unimplemented = Self(
        setMeIfNeeded: XCTUnimplemented("\(Self.self).setMeIfNeeded"),
        updateMe: XCTUnimplemented("\(Self.self).updateMe"),
        users: XCTUnimplemented("\(Self.self).users")
    )

}
