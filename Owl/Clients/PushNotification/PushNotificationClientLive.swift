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
import FirebaseFirestoreSwift

extension PushNotificationClient {

    static func live() -> PushNotificationClient {
        PushNotificationClient(
            getNotificationSettings: getNotificationSettings,
            requestAuthorization: requestAuthorization,
            setAPNSToken: setAPNSToken,
            register: register,
            currentFCMToken: currentFCMToken,
            handlePushNotification: handlePushNotification,
            handleDidReceiveResponse: handleDidReceiveResponse,
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

    static func currentFCMToken() -> Effect<String, NSError> {
        Effect.future { completion in
            FirebaseClient.messaging.token { token, error in
                if let token = token {
                    completion(.success(token))
                } else if let error = error {
                    completion(.failure(error as NSError))
                }
            }
        }
    }

    static func handlePushNotification (
        notification: PushNotificationClient.Notification,
        completionHandler: @escaping (UNNotificationPresentationOptions) -> Void,
        openedChatId: String?
    ) -> Effect<Void, NSError> {
        Effect.result {
            Result<Void, Error> {
                guard let json = notification.request.content.userInfo as? [String: Any] else {
                    throw NSError(domain: "Invalid user info", code: 1)
                }
                let data = try JSONSerialization.data(
                    withJSONObject: json,
                    options: [.fragmentsAllowed]
                )

                let push = try JSONDecoder.customFirestore.decode(Push.self, from: data)
                if push.chat.id == openedChatId {
                    completionHandler([])
                } else {
                    completionHandler([.banner, .sound])
                }
            }
            .mapError { $0 as NSError }
        }
    }

    static func handleDidReceiveResponse(
        response: PushNotificationClient.Response,
        completionHandler: @escaping () -> Void
    ) -> Effect<PushRoute, NSError> {
        Effect.result {
            return Result<PushRoute, Error> {
                guard let json = response.notification.request.content.userInfo as? [String: Any] else {
                    throw NSError(domain: "Invalid user info", code: 1)
                }
                let data = try JSONSerialization.data(withJSONObject: json, options: [.fragmentsAllowed])
                let push = try JSONDecoder.customFirestore.decode(Push.self, from: data)
                completionHandler()
                // There is no routing logic. If we tap on push, we open chat.
                return PushRoute.openChat(push.chat)
            }
            .mapError { $0 as NSError }
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
