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
    let firstName: String?
    let lastName: String?
}

// MARK: - Encodable

extension User: Codable {

    enum CodingKeys: String, CodingKey {
        case uid
        case phoneNumber
        case firstName
        case lastName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(firstName ?? "Wild", forKey: .firstName)
        try container.encode(lastName ?? "Owl", forKey: .lastName)
    }
}

// MARK: - Equatable

extension User: Equatable {

}
