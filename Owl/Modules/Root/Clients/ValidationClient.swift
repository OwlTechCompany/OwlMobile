//
//  ValidationClient.swift
//  Owl
//
//  Created by Denys Danyliuk on 15.04.2022.
//

import Foundation

struct ValidationClient {

    static let phoneRegex = "^\\+[0-9]{3}[0-9]{9}"

    var phoneValidation: (String) -> Bool
}

// MARK: - Live

extension ValidationClient {

    static func live() -> ValidationClient {
        let phoneRegex = "^\\+[0-9]{3}[0-9]{9}"
        return ValidationClient(
            phoneValidation: { phoneValidationLive(phone: $0, regex: phoneRegex) }
        )
    }

    static func phoneValidationLive(
        phone: String,
        regex: String
    ) -> Bool {
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return phoneTest.evaluate(with: phone)
    }
}
