//
//  AppDelegateStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import SwiftUI
import Firebase

struct AppDelegateStore: ReducerProtocol {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(Result<Data, NSError>)
        case didReceiveRemoteNotification(DidReceiveRemoteNotificationModel)
        case sendFCMToken(token: String?)
        case userNotificationCenterDelegate(UserNotificationCenterDelegate.Event)
        case firebaseMessagingDelegate(FirebaseMessagingDelegate.Event)
    }

    @Dependency(\.firebaseClient) var firebaseClient
    @Dependency(\.userClient) var userClient
    @Dependency(\.authClient) var authClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    @Dependency(\.pushNotificationClient) var pushNotificationClient
    @Dependency(\.firestoreChatsClient) var firestoreChatsClient

    // MARK: - Reducer

    var body: some ReducerProtocolOf<Self> {
        Reduce { _, action in
            switch action {
            case .didFinishLaunching:
                firebaseClient.setup()
                userClient.setup()

                let userNotificationCenterDelegateEffect = pushNotificationClient
                    .userNotificationCenterDelegate
                    .map(Action.userNotificationCenterDelegate)

                let firebaseMessagingDelegateEffect = pushNotificationClient
                    .firebaseMessagingDelegate
                    .map(Action.firebaseMessagingDelegate)

                // Register for notifications on startup
                let setupPushNotificationEffect: Effect<AppDelegateStore.Action, Never> = pushNotificationClient
                    .getNotificationSettings
                    .receive(on: DispatchQueue.main)
                    .flatMap { settings in
                        settings.authorizationStatus == .authorized
                        ? pushNotificationClient.requestAuthorization([.alert, .sound])
                        : .none
                    }
                    .receive(on: DispatchQueue.main)
                    .flatMap { isSucceed -> Effect<Never, Never> in
                        isSucceed
                        ? pushNotificationClient.register()
                        : .none
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .fireAndForget()

                return .merge(
                    userNotificationCenterDelegateEffect,
                    firebaseMessagingDelegateEffect,
                    setupPushNotificationEffect
                )

            case let .userNotificationCenterDelegate(.willPresentNotification(notification, completionHandler)):
                return pushNotificationClient
                    .handlePushNotification(
                        notification,
                        completionHandler,
                        firestoreChatsClient.openedChatId.value
                    )
                    .fireAndForget()

            case .userNotificationCenterDelegate:
                return .none

            case let .firebaseMessagingDelegate(.didReceiveRegistrationToken(_, fcmToken)):
                return Effect(value: .sendFCMToken(token: fcmToken))

            case let .didRegisterForRemoteNotifications(.success(data)):
                return .merge(
                    authClient
                        .setAPNSToken(data)
                        .fireAndForget(),

                    Effect.concatenate(
                        pushNotificationClient
                            .setAPNSToken(data)
                            .fireAndForget(),

                        pushNotificationClient
                            .currentFCMToken()
                            .ignoreFailure()
                            .flatMap { Effect(value: .sendFCMToken(token: $0)) }
                            .eraseToEffect()
                    )
                )

            case let .sendFCMToken(token):
                guard let fcmToken = token else {
                    return .none
                }
                let userUpdate = UserUpdate(fcmToken: fcmToken)
                return firestoreUsersClient
                    .updateMe(userUpdate)
                    .fireAndForget()

            case .didRegisterForRemoteNotifications(.failure):
                return .none

            case let .didReceiveRemoteNotification(model):
                authClient.handleIfAuthNotification(model)
                model.completionHandler(.newData)
                return .none
            }
        }
    }

}
