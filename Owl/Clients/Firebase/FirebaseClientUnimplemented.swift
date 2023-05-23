//
//  FirebaseClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import Combine
import XCTestDynamicOverlay

extension FirebaseClient {

    static let unimplemented = Self(
        state: .development(host: "192.0.0.1"),
        setup: XCTUnimplemented("\(Self.self).setup")
    )

}
