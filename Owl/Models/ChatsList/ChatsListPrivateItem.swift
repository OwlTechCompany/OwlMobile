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
    let members: [User]
    let membersIDs: [String]
    let lastMessage: MessageResponse?

}

extension ChatsListPrivateItem {

    var companion: User {
        members.first(where: { $0.uid != FirebaseClient.auth.currentUser!.uid })!
    }

    var me: User {
        members.first(where: { $0.uid == FirebaseClient.auth.currentUser!.uid })!
    }

    var name: String {
        companion.fullName
    }

    var lastMessageAuthorName: String {
        switch lastMessage?.sentBy {
        case me.uid:
            return me.fullName

        case companion.uid:
            return companion.fullName

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
    let membersIDs: [String]
    let members: [User]
    var chatType: String = "private"
}
