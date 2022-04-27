//
//  AppDelegateStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import SwiftUI

struct DidReceiveRemoteNotificationModel: Equatable {
    var userInfo: [AnyHashable: Any]
    var completionHandler: (UIBackgroundFetchResult) -> Void

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.userInfo.keys == lhs.userInfo.keys
    }
}

extension AppDelegate {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(Result<Data, NSError>)
        case didReceiveRemoteNotification(DidReceiveRemoteNotificationModel)
    }

    // MARK: - Environment

    struct Environment {
        let firebaseClient: FirebaseClient
        let userClient: UserClient
        let authClient: AuthClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, environment in
        switch action {
        case .didFinishLaunching:
            environment.firebaseClient.setup()
            environment.userClient.setup()
            return .none

        case let .didRegisterForRemoteNotifications(.success(data)):
            return .merge(
                environment.authClient
                    .setAPNSToken(data)
                    .fireAndForget()
            )

        case let .didRegisterForRemoteNotifications(.failure(error)):
            return .none

        case let .didReceiveRemoteNotification(model):
            return environment.authClient
                .canHandleNotification(model)
                .fireAndForget()
        }
    }

}
