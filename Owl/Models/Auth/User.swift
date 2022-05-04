//
//  User.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Foundation

struct User {

    static let defaultFirstName = "Wild"
    static let defaultLastName = "Owl"

    let uid: String
    let phoneNumber: String?
    let firstName: String?
    let lastName: String?
    let photo: Photo
    var fcmToken: String?
}

// MARK: - Encodable

extension User: Codable {

    enum CodingKeys: String, CodingKey {
        case uid
        case phoneNumber
        case firstName
        case lastName
        case photo
        case fcmToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        photo = try container.decodeIfPresent(Photo.self, forKey: .photo) ?? .placeholder
        fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(firstName ?? User.defaultFirstName, forKey: .firstName)
        try container.encode(lastName ?? User.defaultLastName, forKey: .lastName)
        try container.encode(photo, forKey: .photo)
        try container.encode(fcmToken, forKey: .fcmToken)
    }
}

// MARK: - Equatable

extension User: Equatable {

}

// MARK: - Computable

extension User {

    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}
