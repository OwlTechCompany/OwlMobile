//
//  UserUpdate.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Foundation

struct UserUpdate {
    let firstName: String?
    let lastName: String?
    let photo: URL?
}

// MARK: - Encodable

extension UserUpdate: Encodable {

}
