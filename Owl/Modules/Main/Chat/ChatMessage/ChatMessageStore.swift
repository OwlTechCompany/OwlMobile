//
//  ChatMessageStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI

struct ChatMessage {

    // MARK: - State

    struct State: Equatable {
        let text: String
        let sentAt: Date
        let sentBy: String
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

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        return .none
    }

}
