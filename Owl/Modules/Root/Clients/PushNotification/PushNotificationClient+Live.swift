//
//  PushNotificationClient+Live.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import Foundation
import Combine
import Firebase
import ComposableArchitecture
import UIKit

extension PushNotificationClient {

    static func live() -> PushNotificationClient {
        PushNotificationClient(
            getNotificationSettings: getNotificationSettings,
            requestAuthorization: requestAuthorization,
            setAPNSToken: setAPNSToken,
            register: register,
            currentFCMToken: { currentFCMToken() },
            userNotificationCenterDelegate: userNotificationCenterDelegate,
            firebaseMessagingDelegate: firebaseMessagingDelegate
        )
    }

}

fileprivate extension PushNotificationClient {

    static var getNotificationSettings: Effect<Settings, Never> {
        Effect.future { callback in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                callback(.success(.init(rawValue: settings)))
            }
        }
    }

    static func requestAuthorization(authOptions: UNAuthorizationOptions) -> Effect<Bool, NSError> {
        Effect.future { callback in
            UNUserNotificationCenter.current()
                .requestAuthorization(options: authOptions) { granted, error in
                    if let error = error {
                        callback(.failure(error as NSError))
                    } else {
                        callback(.success(granted))
                    }
                }
        }
    }

    static func setAPNSToken(data: Data) {
        Messaging.messaging().apnsToken = nil
        Messaging.messaging().apnsToken = data
    }

    static func register() -> Effect<Never, Never> {
        Effect.fireAndForget {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    static func currentFCMToken() -> Effect<String, Never> {
        Effect.future { completion in
            Messaging.messaging().token { token, error in
                if let error = error {
//                    completion(.failure(.))
                } else if let token = token {
                    completion(.success(token))
                }
            }
        }
    }

    static var userNotificationCenterDelegate: Effect<UserNotificationCenterDelegate.Event, Never> {
        Effect
            .run { subscriber in
                var delegate: Optional = UserNotificationCenterDelegate(subscriber: subscriber)
                UNUserNotificationCenter.current().delegate = delegate
                return AnyCancellable {
                    delegate = nil
                }
            }
            .share()
            .eraseToEffect()
    }

    static var firebaseMessagingDelegate: Effect<FirebaseMessagingDelegate.Event, Never> {
        Effect
            .run { subscriber in
                var delegate: Optional = FirebaseMessagingDelegate(subscriber: subscriber)
                Messaging.messaging().delegate = delegate
                return AnyCancellable {
                    delegate = nil
                }
            }
            .share()
            .eraseToEffect()
    }
}
