//
//  AppDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import UIKit
import ComposableArchitecture
import Firebase
import FirebaseAuth

// MARK: - Implementation

final class AppDelegate: NSObject, UIApplicationDelegate {

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
            return .merge(
                environment.firebaseClient.setup().fireAndForget()
            )

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

    // MARK: - Store

    lazy var appDelegateStore = OwlApp.store.scope(
        state: \App.State.appDelegate,
        action: App.Action.appDelegate
    )
    lazy var viewStore: ViewStore<State, Action> = ViewStore(
        appDelegateStore,
        removeDuplicates: ==
    )

    // MARK: - Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewStore.send(.didFinishLaunching)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        viewStore.send(.didRegisterForRemoteNotifications(.success(deviceToken)))
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        viewStore.send(
            .didRegisterForRemoteNotifications(.failure(error as NSError))
        )
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        viewStore.send(.didReceiveRemoteNotification(userInfo, completionHandler))
    }
}
