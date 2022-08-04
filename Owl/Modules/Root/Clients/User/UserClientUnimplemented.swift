//
//  UserClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import Combine
import XCTestDynamicOverlay

extension UserClient {

    static let unimplemented = Self(
        authUser: CurrentValueSubject(nil),
        firestoreUser: CurrentValueSubject(nil),
        setup: XCTUnimplemented("\(Self.self).setup")
    )

}
