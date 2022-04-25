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

struct ChatsListPrivateItem: Codable, Equatable {

    let id: String
    let createdAt: Date
    let createdBy: String
    let members: [String]
    let user1: User
    let user2: User
    let lastMessage: Message?

}

extension ChatsListPrivateItem {

    var companion: User {
        if user1.uid == Auth.auth().currentUser!.uid {
            return user2
        } else {
            return user1
        }
    }

    var me: User {
        if user1.uid != Auth.auth().currentUser!.uid {
            return user2
        } else {
            return user1
        }
    }

    var name: String {
        return companion.fullName
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
