//
//  NewPrivateChatCellStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct NewPrivateChatCell {

    // MARK: - State

    struct State: Equatable, Identifiable {
        let id: String
        let image: UIImage
        let fullName: String
        let phoneNumber: String
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
