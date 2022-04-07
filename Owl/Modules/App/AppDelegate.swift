//
//  AppDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct AppDelegateState: Codable, Equatable {

}

// MARK: - Action

enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(Result<Data, NSError>)
}

// MARK: - Environment

struct AppDelegateEnvironment {
    let firebaseClient: FirebaseClient
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

    case .didRegisterForRemoteNotifications:
        return .none
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
}
