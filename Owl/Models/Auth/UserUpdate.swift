//
//  UserUpdate.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import Foundation

struct UserUpdate {
    var firstName: String?
    var lastName: String?
    var photo: URL?
    var fcmToken: String?
}

// MARK: - Encodable

extension UserUpdate: Encodable {

}
