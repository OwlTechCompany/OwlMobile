//
//  ChatNavigationStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 17.04.2022.
//

import ComposableArchitecture
import SwiftUI

struct ChatNavigation {

    // MARK: - State

    struct State: Equatable {
        let chatImage: Image
        let chatName: String
        let chatDescription: String
    }

    // MARK: - Action

    enum Action: Equatable {
        case back
        case chatDetails
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .back:
            return .none

        case .chatDetails:
            return .none
        }
    }

}

extension ChatNavigation.State {

    init(model: ChatsListPrivateItem) {
        let nameFirstLater = model.companion.firstName?.first ?? "o"
        self.chatImage = Image(
            systemName: "\(String(nameFirstLater).lowercased()).circle"
        )
        self.chatName = model.name
        self.chatDescription = model.companion.phoneNumber ?? ""
    }

}
