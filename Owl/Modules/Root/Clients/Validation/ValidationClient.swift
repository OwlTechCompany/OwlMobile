//
//  ValidationClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 15.04.2022.
//

import Foundation
import ComposableArchitecture

struct ValidationClient {

    var phoneValidation: (String) -> Bool
    
}

extension DependencyValues {

    var validationClient: ValidationClient {
        get { self[ValidationClientKey.self] }
        set { self[ValidationClientKey.self] = newValue }
    }

    enum ValidationClientKey: DependencyKey {
        static var testValue = ValidationClient.unimplemented
        static let liveValue = ValidationClient.live()
    }

}
