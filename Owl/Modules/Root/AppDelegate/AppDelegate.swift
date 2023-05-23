//
//  AppDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import UIKit
import ComposableArchitecture
import FirebaseMessaging

final class AppDelegate: NSObject, UIApplicationDelegate {

    let store: StoreOf<App> = {
        Store(
            initialState: App.State(),
            reducer: App()
        )
    }()

    // MARK: - Store

    lazy var viewStore: ViewStoreOf<AppDelegateStore> = ViewStore(
        store.scope(
            state: \App.State.appDelegate,
            action: App.Action.appDelegate
        ),
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
        let model = DidReceiveRemoteNotificationModel(
            userInfo: userInfo,
            completionHandler: completionHandler
        )
        viewStore.send(.didReceiveRemoteNotification(model))
    }
}
