//
//  SetupPermissionsStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import ComposableArchitecture
import FirebaseMessaging

struct SetupPermissions {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case grandPermission
        case later
        case requestAuthorizationResult(Result<Bool, NSError>)
        case next
    }

    // MARK: - Environment

    struct Environment {
        var pushNotificationClient: PushNotificationClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, environment in
        switch action {
        case .grandPermission:
            return environment.pushNotificationClient
                .requestAuthorization([.alert, .sound, .badge])
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.requestAuthorizationResult)

        case .later:
            return .none

        case let .requestAuthorizationResult(.success(result)):
            return Effect.concatenate(
                environment.pushNotificationClient
                    .register()
                    .fireAndForget(),

                Effect(value: .next)
            )

        case .requestAuthorizationResult(.failure):
            return .none

        case .next:
            return .none
        }
    }

}
