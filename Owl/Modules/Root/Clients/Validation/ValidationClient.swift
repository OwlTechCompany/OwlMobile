//
//  ValidationClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 15.04.2022.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

struct ValidationClient {

    var phoneValidation: (String) -> Bool
    
}

extension ValidationClient {

    static let unimplemented = Self(
        phoneValidation: XCTUnimplemented("\(Self.self).phoneValidation")
    )

}

extension DependencyValues {

    var validationClient: ValidationClient {
        get {
            self[ValidationClientKey.self]
        }
        set {
            self[ValidationClientKey.self] = newValue
        }
    }

    enum ValidationClientKey: DependencyKey {
        static var testValue = ValidationClient.unimplemented
    }

}
