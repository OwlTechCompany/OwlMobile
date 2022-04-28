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
        case didReceiveRemoteNotification(DidReceiveRemoteNotificationModel)
    }

    // MARK: - Environment

    struct Environment {
        let firebaseClient: FirebaseClient
        let userClient: UserClient
        let authClient: AuthClient
        let pushNotificationClient: PushNotificationClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, environment in
        switch action {
        case .didFinishLaunching:
            environment.firebaseClient.setup()
            environment.userClient.setup()

//            return .none
            return environment.pushNotificationClient.registerForRemoteNotifications()
                .receive(on: DispatchQueue.main)
                .map { value in
                    UIApplication.shared.registerForRemoteNotifications()
                }
                .fireAndForget()
            

        case let .didRegisterForRemoteNotifications(.success(data)):
            return .merge(
                environment.authClient
                    .setAPNSToken(data)
                    .fireAndForget(),
                environment.pushNotificationClient
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
