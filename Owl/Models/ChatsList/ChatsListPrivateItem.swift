//
//  ChatsListPrivateItem.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

struct ChatsListPrivateItem: Decodable, Equatable {

    let id: String
    let createdAt: Date
    let updatedAt: Date?
    let createdBy: String
    let members: [String]
    let user1: User
    let user2: User
    let lastMessage: MessageResponse?

}

extension ChatsListPrivateItem {

    var companion: User {
        user1.uid == FirebaseClient.auth.currentUser!.uid
        ? user2
        : user1
    }

    var me: User {
        user1.uid == FirebaseClient.auth.currentUser!.uid
        ? user1
        : user2
    }

    var name: String {
        companion.fullName
    }

    var lastMessageAuthorName: String {
        switch lastMessage?.sentBy {
        case user1.uid:
            return user1.fullName

        case user2.uid:
            return user2.fullName

        default:
            return String()
        }
    }

}


struct PrivateChatCreate: Encodable {

    var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var updatedAt: Timestamp?
    let createdBy: String
    let members: [String]
    let user1: User
    let user2: User
    var chatType: String = "private"
}
