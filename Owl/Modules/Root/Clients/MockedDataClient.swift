//
//  MockedDataClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import SwiftUI

struct MockedDataClient {

    static let chatsListPrivateItem = ChatsListPrivateItem(
        id: "123",
        createdAt: Date(),
        createdBy: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3",
        members: [
            "5vhdMunt5FgHTBnaNTQHpM3qIhJ3",
            "f1jCGeHXjbSrMWmGb7E2q6CX4xx1"
        ],
        user1: User(
            uid: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3",
            phoneNumber: "+380931314850",
            firstName: "Anastasia",
            lastName: "No"
        ),
        user2: User(
            uid: "f1jCGeHXjbSrMWmGb7E2q6CX4xx1",
            phoneNumber: "+380991111111",
            firstName: "Denys",
            lastName: "No"
        ),
        lastMessage: Message(
            messageText: "Cool!😊 let's meet at 16:00. Jklndjf dkf jkss djfn ljf fkhshfkeune fjufuufukk klfn fjj fjufuufukk k",
            sentAt: Date(),
            sentBy: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3"
        )
    )

    static let chatNavigationState = ChatNavigation.State(
        chatImage: Image(systemName: "pawprint"),
        chatName: "Namehello World",
        chatDescription: "+380931314850"
    )

}
