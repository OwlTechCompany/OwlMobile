//
//  AppDelegateStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import SwiftUI
import Firebase

extension AppDelegate {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case didFinishLaunching
        case didRegisterForRemoteNotifications(Result<Data, NSError>)
        case didReceiveRemoteNotification(DidReceiveRemoteNotificationModel)
        case userNotificationCenterDelegate(UserNotificationCenterDelegate.Event)

        case sendFCMToken(token: String?)

        case firebaseMessagingDelegate(FirebaseMessagingDelegate.Event)
    }

    // MARK: - Environment

    struct Environment {
        let firebaseClient: FirebaseClient
        let userClient: UserClient
        let authClient: AuthClient
        let firestoreUserClient: FirestoreUsersClient
        let pushNotificationClient: PushNotificationClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, environment in
        switch action {
        case .didFinishLaunching:
            environment.firebaseClient.setup()
            environment.userClient.setup()

            let userNotificationCenterDelegateEffect = environment
                .pushNotificationClient
                .userNotificationCenterDelegate
                .map(Action.userNotificationCenterDelegate)

            let firebaseMessagingDelegateEffect = environment
                .pushNotificationClient
                .firebaseMessagingDelegate
                .map(Action.firebaseMessagingDelegate)

            let setupPushNotificationEffect: Effect<AppDelegate.Action, Never> = environment
                .pushNotificationClient
                .getNotificationSettings
                .receive(on: DispatchQueue.main)
                .flatMap { settings in
                    settings.authorizationStatus == .authorized
                        ? environment.pushNotificationClient.requestAuthorization([.alert, .sound])
                        : .none
                }
                .receive(on: DispatchQueue.main)
                .flatMap { isSucceed -> Effect<Never, Never> in
                    isSucceed
                        ? environment.pushNotificationClient.register()
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
            return environment.pushNotificationClient
                .handlePushNotification(notification, completionHandler)
                .fireAndForget()

        case .userNotificationCenterDelegate:
            return .none

        case let .firebaseMessagingDelegate(.didReceiveRegistrationToken(_, fcmToken)):
            return Effect(value: .sendFCMToken(token: fcmToken))

        case let .didRegisterForRemoteNotifications(.success(data)):
            return .merge(
                environment.authClient
                    .setAPNSToken(data)
                    .fireAndForget(),

                Effect.concatenate(
                    environment.pushNotificationClient
                        .setAPNSToken(data)
                        .fireAndForget(),

                    environment.pushNotificationClient
                        .currentFCMToken()
                        .flatMap { Effect(value: .sendFCMToken(token: $0)) }
                        .eraseToEffect()
                )
            )

        case let .sendFCMToken(token):
            guard let fcmToken = token else {
                return .none
            }
            let userUpdate = UserUpdate(fcmToken: fcmToken)
            return environment.firestoreUserClient
                .updateMe(userUpdate)
                .fireAndForget()

        case let .didRegisterForRemoteNotifications(.failure(error)):
            return .none

        case let .didReceiveRemoteNotification(model):
            environment.authClient.handleIfAuthNotification(model)
            model.completionHandler(.newData)
            return .none
        }
    }

}
