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
    let photo: UserPhoto

    enum UserPhoto: Codable, Equatable {
        case url(URL)
        case placeholder

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let url = try? container.decode(URL.self) {
                self = .url(url)
            } else {
                self = .placeholder
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .url(url):
                return try container.encode(url)
            case .placeholder:
                return try container.encodeNil()
            }
        }
    }
}

import SwiftUI

extension CachedAsyncImage where Content == Image {

    init(
        user: User?,
        urlCache: URLCache = .imageCache,
        transaction: Transaction = Transaction()
    ) {
        switch user?.photo {
        case let .url(url):
            self.init(
                url: url,
                urlCache: urlCache,
                scale: 1,
                transaction: transaction
            ) { phase in
                var result: Image = Image("")
                switch phase {
                case .empty:
                    result = Image(uiImage: Asset.Images.gradientOwl.image)
                case .success(let image):
                    result = image
                case .failure:
                    result = Image(uiImage: Asset.Images.gradientOwl.image)
                @unknown default:
                    result = Image(uiImage: Asset.Images.gradientOwl.image)
                }
                return result
                    .resizable()
            }

        case .placeholder:
            self.init(
                urlRequest: nil,
                urlCache: urlCache,
                scale: 1,
                transaction: transaction
            ) { _ in
                Image(uiImage: Asset.Images.gradientOwl.image)
                    .resizable()
            }
            
        case .none:
            self.init(
                urlRequest: nil,
                urlCache: urlCache,
                scale: 1,
                transaction: transaction
            ) { _ in
                Image(uiImage: Asset.Images.gradientOwl.image)
                    .resizable()
            }
        }
    }
}

// MARK: - Encodable

extension User: Codable {

    enum CodingKeys: String, CodingKey {
        case uid
        case phoneNumber
        case firstName
        case lastName
        case photo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        photo = try container.decodeIfPresent(UserPhoto.self, forKey: .photo) ?? .placeholder
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(firstName ?? User.defaultFirstName, forKey: .firstName)
        try container.encode(lastName ?? User.defaultLastName, forKey: .lastName)
        try container.encode(photo, forKey: .photo)
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
