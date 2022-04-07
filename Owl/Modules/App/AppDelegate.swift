//
//  AppDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct UserSettings: Codable, Equatable {

}

// MARK: - Action

enum AppDelegateAction: Equatable {
    case didFinishLaunching
    case didRegisterForRemoteNotifications(Result<Data, NSError>)
}

// MARK: - Environment

struct AppDelegateEnvironment {

}

// MARK: - Reducer

/*
let appDelegateReducer = Reducer<
    UserSettings, AppDelegateAction, AppDelegateEnvironment
> { state, action, environment in
    switch action {
    case .didFinishLaunching:
        return .none
    case .didRegisterForRemoteNotifications:
        return .none
    }
}
*/

// MARK: - Implementation

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(
        initialState: .init(),
        reducer: appReducer,
        environment: .init()
    )
    lazy var viewStore = ViewStore(
        store.scope(state: { _ in () }),
        removeDuplicates: ==
    )

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        viewStore.send(.appDelegate(.didFinishLaunching))
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        viewStore.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        viewStore.send(
            .appDelegate(.didRegisterForRemoteNotifications(.failure(error as NSError)))
        )
    }
}
