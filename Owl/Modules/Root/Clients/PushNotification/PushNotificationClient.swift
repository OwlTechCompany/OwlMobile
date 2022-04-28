//
//  PushNotificationClient.swift
//  Owl
//
//  Created by Anastasia Holovash on 08.04.2022.
//

import Foundation
import Combine
import Firebase
import ComposableArchitecture

struct PushNotificationClient {

    var registerForRemoteNotifications: () -> Effect<Bool, NSError>
    var pushNotificationDelegate: Effect<PushNotificationDelegate.Event, Never>
    var firebaseMessagingDelegate: Effect<FirebaseMessagingDelegate.Event, Never>
    
    var setAPNSToken: (Data) -> Void
}

// MARK: - Live

extension PushNotificationClient {

    static func live() -> PushNotificationClient {
        PushNotificationClient(
            registerForRemoteNotifications: registerForRemoteNotificationsLive,
            pushNotificationDelegate: pushNotificationDelegateLive,
            firebaseMessagingDelegate: firebaseMessagingDelegateLive,
            setAPNSToken: setAPNSToken
        )
    }

    static private var pushNotificationDelegateLive: Effect<PushNotificationDelegate.Event, Never> {
        Effect
            .run { subscriber in
                var delegate: Optional = PushNotificationDelegate(subscriber: subscriber)
                UNUserNotificationCenter.current().delegate = delegate
                return AnyCancellable {
                    delegate = nil
                }
            }
            .share()
            .eraseToEffect()
    }

    static private var firebaseMessagingDelegateLive: Effect<FirebaseMessagingDelegate.Event, Never> {
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

    static private func registerForRemoteNotificationsLive() -> Effect<Bool, NSError> {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        return Effect.future { callback in
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

    static private func setAPNSToken(data: Data) {
        Messaging.messaging().apnsToken = data
    }
}
