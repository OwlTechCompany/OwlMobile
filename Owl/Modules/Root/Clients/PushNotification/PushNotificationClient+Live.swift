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
import AVKit

extension PushNotificationClient {

    static func live() -> PushNotificationClient {
        PushNotificationClient(
            getNotificationSettings: getNotificationSettings,
            requestAuthorization: requestAuthorization,
            setAPNSToken: setAPNSToken,
            register: register,
            currentFCMToken: { currentFCMToken() },
            handlePushNotification: handlePushNotification,
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

    static func setAPNSToken(data: Data) -> Effect<Void, Never> {
        Effect.fireAndForget {
            FirebaseClient.messaging.apnsToken = data
        }
    }

    static func register() -> Effect<Never, Never> {
        Effect.fireAndForget {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    static func currentFCMToken() -> Effect<String, Never> {
        Effect.future { completion in
            FirebaseClient.messaging.token { token, _ in
                if let token = token {
                    completion(.success(token))
                }
            }
        }
    }

    static func handlePushNotification (
        notification: PushNotificationClient.Notification,
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) -> Effect<Void, Never> {
        Effect.fireAndForget {
            guard
                let json = notification.request.content.userInfo as? [String: Any]
            else {
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject: json)
                let push = try JSONDecoder().decode(Push.self, from: data)
                if push.chatId == openedChatId {
                    completionHandler([])
                    // TODO: Move to Chat view
                    AudioServicesPlayAlertSound(1301)
                } else {
                    completionHandler([.banner, .sound])
                }
            } catch let error {
                print(error.localizedDescription)
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
                FirebaseClient.messaging.delegate = delegate
                return AnyCancellable {
                    delegate = nil
                }
            }
            .share()
            .eraseToEffect()
    }
}
