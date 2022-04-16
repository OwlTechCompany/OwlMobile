//
//  AppDelegateStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import SwiftUI

extension AppDelegate {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(Result<Data, NSError>)
        case didReceiveRemoteNotification(
            _ userInfo: [AnyHashable: Any],
            _ completionHandler: (UIBackgroundFetchResult) -> Void
        )

        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.didFinishLaunching, .didFinishLaunching):
                return true

            case let (.didRegisterForRemoteNotifications(lhs), .didRegisterForRemoteNotifications(rhs)):
                return lhs == rhs

            case let (.didReceiveRemoteNotification(lhs, _), .didReceiveRemoteNotification(rhs, _)):
                return lhs.keys == rhs.keys

            default:
                return false
            }
        }
    }

    // MARK: - Environment

    struct Environment {
        let firebaseClient: FirebaseClient
        let authClient: AuthClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, environment in
        switch action {
        case .didFinishLaunching:
            environment.firebaseClient.setup()
            return .none

        case let .didRegisterForRemoteNotifications(.success(data)):
            return .merge(
                environment.authClient
                    .setAPNSToken(data)
                    .fireAndForget()
            )

        case let .didRegisterForRemoteNotifications(.failure(error)):
            return .none

        case let .didReceiveRemoteNotification(userInfo, completionHandler):
            return .merge(
                environment.authClient
                    .canHandleNotification(userInfo, completionHandler)
                    .fireAndForget()
            )
        }
    }

}
