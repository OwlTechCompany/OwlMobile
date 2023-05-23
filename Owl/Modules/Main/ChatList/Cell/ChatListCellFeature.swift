//
//  ChatListCellFeature.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatListCellFeature: Reducer {
    
    struct State: Equatable, Identifiable {
        let id: String
        let photo: Photo
        let chatName: String
        let lastMessageAuthorName: String
        let lastMessage: String
        let lastMessageSendTime: Date
        let unreadMessagesNumber: Int
    }
    
    enum Action: Equatable {
        case open
    }
    
    var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
}

extension ChatListCellFeature.State {
    
    init(model: ChatsListPrivateItem) {
        id = model.id
        photo = model.companion.photo
        chatName = model.name
        lastMessageAuthorName = model.lastMessageAuthorName
        lastMessage = model.lastMessage?.messageText ?? ""
        lastMessageSendTime = model.lastMessage?.sentAt ?? Date()
        unreadMessagesNumber = 0
    }
    
}
