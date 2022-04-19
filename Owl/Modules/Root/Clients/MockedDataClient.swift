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
            id: "1",
            messageText: "Cool!😊 let's meet at 16:00. Jklndjf dkf jkss djfn ljf fkhshfkeune fjufuufukk klfn fjj fjufuufukk k",
            sentAt: Date(),
            sentBy: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3"
        )
    )

    static let chatMessages = [
        Message(
            id: "1",
            messageText: "But I must explain to you how all this mistaken idea?",
            sentAt: Date(),
            sentBy: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3"
        ),
        Message(
            id: "2",
            messageText: "Cool!😊 let's meet at 16:00. Jklndjf dkf jkss djfn ljf fkhshfkeune fjufuufukk klfn fjj fjufuufukk k",
            sentAt: Date(),
            sentBy: "f1jCGeHXjbSrMWmGb7E2q6CX4xx1"
        ),
        Message(
            id: "3",
            messageText: "no resultant pleasure 👍",
            sentAt: Date(),
            sentBy: "f1jCGeHXjbSrMWmGb7E2q6CX4xx1"
        ),
        Message(
            id: "4",
            messageText: "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis",
            sentAt: Date(),
            sentBy: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3"
        ),
        Message(
            id: "5",
            messageText: "Ha every!",
            sentAt: Date(),
            sentBy: "5vhdMunt5FgHTBnaNTQHpM3qIhJ3"
        ),
    ]

}
