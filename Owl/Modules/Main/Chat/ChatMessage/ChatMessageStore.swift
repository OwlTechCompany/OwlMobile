//
//  ChatMessageStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI
import Firebase

struct ChatMessage {

    // MARK: - State

    struct State: Equatable, Identifiable, Hashable {
        let id: String
        let text: String
        let sentAt: Timestamp?
        let sentBy: String // Not used for now; Added for groups
        let type: MessageType
    }

    enum MessageType {
        case sentByMe
        case sentForMe
    }

    // MARK: - Action

    enum Action: Equatable {

    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, _, _ in
        return .none
    }

}

extension ChatMessage.State {

    init(message: MessageResponse, companion: User) {
        self.id = message.id
        self.text = message.messageText
        self.sentAt = message.sentAt
        self.sentBy = message.sentBy
        self.type = message.sentBy == companion.uid ? .sentForMe : .sentByMe
    }
    
}
