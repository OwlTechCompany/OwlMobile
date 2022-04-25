//
//  ProfileStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 18.04.2022.
//

import ComposableArchitecture
import UIKit

struct Profile {

    // MARK: - State

    struct State: Equatable {
        var alert: AlertState<Action>?
        var image: UIImage
    }

    // MARK: - Action

    enum Action: Equatable {
        case close

        case logoutTapped
        case logout

        case dismissAlert
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .close:
            return .none

        case .logoutTapped:
            state.alert = .init(
                title: TextState("Are you sure?"),
                primaryButton: .cancel(TextState("Cancel")),
                secondaryButton: .destructive(
                    TextState("Logout"),
                    action: .send(.logout)
                )
            )
            return .none

        case .logout:
            return .none

        case .dismissAlert:
            state.alert = nil
            return .none
        }
    }

}
