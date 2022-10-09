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
        lastMessage?.sentBy == user1.uid
        ? user1.fullName
        : user2.fullName
    }

}


struct PrivateChatCreate: Encodable {

    var id: String?
    @ServerTimestamp var createdAt: Timestamp?
    let createdBy: String
    let members: [String]
    let user1: User
    let user2: User
    var chatType: String = "private"
}
