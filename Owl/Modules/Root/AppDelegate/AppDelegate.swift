//
//  AppDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import UIKit
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {

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
