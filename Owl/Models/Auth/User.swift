//
//  User.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Foundation

struct User {
    let uid: String
    let phoneNumber: String?
}

// MARK: - Encodable

extension User: Encodable {

}
