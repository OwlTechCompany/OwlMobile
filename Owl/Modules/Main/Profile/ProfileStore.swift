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
        var user: User
        var alert: AlertState<Action>?
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case close

        case updateUser(User)

        case logoutTapped
        case logout

        case dismissAlert
    }

    // MARK: - Environment

    struct Environment {
        let userClient: UserClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            return Effect.run { subscriber in
                environment.userClient.firestoreUser
                    .dropFirst()
                    .compactMap { $0 }
                    .sink { user in
                        subscriber.send(.updateUser(user))
                    }
            }

        case let .updateUser(user):
            state.user = user
            return .none

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
