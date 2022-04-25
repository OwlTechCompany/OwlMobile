//
//  ChatWithUserResponse.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import Foundation

enum ChatWithUserResponse: Equatable {
    case chatItem(ChatsListPrivateItem)
    case needToCreate(withUserID: String)
}
