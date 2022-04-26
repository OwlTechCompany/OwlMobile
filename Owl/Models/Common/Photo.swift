//
//  Photo.swift
//  Owl
//
//  Created by Denys Danyliuk on 27.04.2022.
//

import Foundation

enum Photo: Codable, Equatable {
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
