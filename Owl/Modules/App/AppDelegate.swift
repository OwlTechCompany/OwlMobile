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

// MARK: - State

struct AppDelegateState: Codable, Equatable {

}

// MARK: - Action

enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(Result<Data, NSError>)
    case didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        _ completionHandler: (UIBackgroundFetchResult) -> Void
    )

    static func == (lhs: AppDelegateAction, rhs: AppDelegateAction) -> Bool {
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

struct AppDelegateEnvironment {
    let firebaseClient: FirebaseClient
    let authClient: AuthClient
}

// MARK: - Reducer

let appDelegateReducer = Reducer<
    AppDelegateState, AppDelegateAction, AppDelegateEnvironment
> { _, action, environment in
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

// MARK: - Implementation

final class AppDelegate: NSObject, UIApplicationDelegate {

    lazy var appDelegateStore = OwlApp.store.scope(
        state: \AppState.appDelegate,
        action: AppAction.appDelegate
    )
    lazy var viewStore = ViewStore(
        appDelegateStore,
        removeDuplicates: ==
    )

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
