//
//  UpdateUser.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Foundation

struct UpdateUser {
    let firstName: String?
    let lastName: String?
}

// MARK: - Encodable

extension UpdateUser: Encodable {

}
