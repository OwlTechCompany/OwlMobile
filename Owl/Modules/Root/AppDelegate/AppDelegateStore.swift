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
        case pushNotificationDelegate(PushNotificationDelegate.Event)
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

            return
                .merge(
                    environment
                        .pushNotificationClient
                        .pushNotificationDelegate
                        .map(Action.pushNotificationDelegate),

                    environment
                        .pushNotificationClient
                        .firebaseMessagingDelegate
                        .map(Action.firebaseMessagingDelegate)
                )
//            return environment.pushNotificationClient.registerForRemoteNotifications()
//                .receive(on: DispatchQueue.main)
//                .map { value in
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//                .fireAndForget()

        case let .pushNotificationDelegate(.willPresentNotification(notification, completionHandler)):
            return .fireAndForget {
                completionHandler([.banner, .sound])
            }

        case .pushNotificationDelegate:
            return .none

        case let .firebaseMessagingDelegate(.didReceiveRegistrationToken(_, fcmToken)):
            guard let fcmToken = fcmToken else {
                return .none
            }
            let userUpdate = UserUpdate(fcmToken: fcmToken)
            return environment.firestoreUserClient
                .updateMe(userUpdate)
                .fireAndForget()

        case let .didRegisterForRemoteNotifications(.success(data)):

            environment.authClient.setAPNSToken(data)
            environment.pushNotificationClient.setAPNSToken(data)
            return .none

        case let .didRegisterForRemoteNotifications(.failure(error)):
            return .none

        case let .didReceiveRemoteNotification(model):
            environment.authClient
                .canHandleNotification(model)
            model.completionHandler(.newData)
            return .none
        }
    }

}
