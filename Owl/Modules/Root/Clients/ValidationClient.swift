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

    static let live = ValidationClient(
        phoneValidation: { phone in
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return phoneTest.evaluate(with: phone)
        }
    )
}
