//
//  ValidationClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import XCTestDynamicOverlay

extension ValidationClient {

    static let unimplemented = Self(
        phoneValidation: XCTUnimplemented("\(Self.self).phoneValidation")
    )

}
