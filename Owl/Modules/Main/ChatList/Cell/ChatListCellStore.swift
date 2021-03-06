//
//  ChatListCellStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatListCell {

    // MARK: - State

    struct State: Equatable, Identifiable {
        let id: String
        let photo: Photo
        let chatName: String
        let lastMessage: String
        let lastMessageSendTime: Date
        let unreadMessagesNumber: Int
    }

    // MARK: - Action

    enum Action: Equatable {
        case open
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .open:
            return .none
        }
    }
}

extension ChatListCell.State {

    init(model: ChatsListPrivateItem) {
        id = model.id
        photo = model.companion.photo
        chatName = model.name
        lastMessage = model.lastMessage?.messageText ?? ""
        lastMessageSendTime = model.lastMessage?.sentAt?.dateValue() ?? Date()
        unreadMessagesNumber = 0
    }

}
