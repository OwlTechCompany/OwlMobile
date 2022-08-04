//
//  ValidationClientLive.swift
//  Owl
//
//  Created by Denys Danyliuk on 15.04.2022.
//

import Foundation
import ComposableArchitecture

extension ValidationClient {

    static func live() -> ValidationClient {
        let phoneRegex = "^\\+[0-9]{3}[0-9]{9}"
        return ValidationClient(
            phoneValidation: { phoneValidation(phone: $0, regex: phoneRegex) }
        )
    }

}

fileprivate extension ValidationClient {

    static func phoneValidation(
        phone: String,
        regex: String
    ) -> Bool {
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return phoneTest.evaluate(with: phone)
    }

}
