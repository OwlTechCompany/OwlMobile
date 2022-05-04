//
//  ValidationClientLive.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.05.2022.
//

import Foundation

extension ValidationClient {

    static func live() -> ValidationClient {
        let phoneRegex = "^\\+[0-9]{3}[0-9]{9}"
        return ValidationClient(
            phoneValidation: { phoneValidation(phone: $0, regex: phoneRegex) }
        )
    }

}

private extension ValidationClient {

    static func phoneValidation(
        phone: String,
        regex: String
    ) -> Bool {
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return phoneTest.evaluate(with: phone)
    }

}
