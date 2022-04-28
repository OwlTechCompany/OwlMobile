//
//  SetupPermissionsStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import ComposableArchitecture

struct SetupPermissions {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case grandPermission
        case later
        case registerForRemoteNotificationsResult(Result<Bool, NSError>)
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
                .catchToEffect(Action.registerForRemoteNotificationsResult)

        case .later:
            return .none

        case let .registerForRemoteNotificationsResult(.success(result)):
            return Effect(value: .next)

        case .registerForRemoteNotificationsResult(.failure):
            return .none

        case .next:
            return .none
        }
    }

}
