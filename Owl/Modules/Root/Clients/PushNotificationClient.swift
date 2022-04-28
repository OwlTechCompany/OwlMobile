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
    var delegate: Effect<DelegateEvent, Never>
    var setAPNSToken: (Data) -> Effect<Bool, NSError>
}

// MARK: - Delegate

extension PushNotificationClient {

    enum DelegateEvent: Equatable {
        case didReceiveResponse(Notification.Response, completionHandler: () -> Void)
        case openSettingsForNotification(Notification?)
        case willPresentNotification(
            Notification, completionHandler: (UNNotificationPresentationOptions) -> Void)

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.didReceiveResponse(lhs, _), .didReceiveResponse(rhs, _)):
                return lhs == rhs
            case let (.openSettingsForNotification(lhs), .openSettingsForNotification(rhs)):
                return lhs == rhs
            case let (.willPresentNotification(lhs, _), .willPresentNotification(rhs, _)):
                return lhs == rhs
            default:
                return false
            }
        }
    }

    struct Notification: Equatable {
        var date: Date
        var request: UNNotificationRequest

        init(
            date: Date,
            request: UNNotificationRequest
        ) {
            self.date = date
            self.request = request
        }

        struct Response: Equatable {
            var notification: Notification

            init(notification: Notification) {
                self.notification = notification
            }
        }
    }

    public struct Settings: Equatable {
        public var authorizationStatus: UNAuthorizationStatus

        public init(authorizationStatus: UNAuthorizationStatus) {
            self.authorizationStatus = authorizationStatus
        }
    }

    fileprivate class Delegate: NSObject, UNUserNotificationCenterDelegate {
        let subscriber: Effect<PushNotificationClient.DelegateEvent, Never>.Subscriber

        init(subscriber: Effect<PushNotificationClient.DelegateEvent, Never>.Subscriber) {
            self.subscriber = subscriber
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            self.subscriber.send(
                .didReceiveResponse(.init(rawValue: response), completionHandler: completionHandler)
            )
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            openSettingsFor notification: UNNotification?
        ) {
            self.subscriber.send(
                .openSettingsForNotification(notification.map(Notification.init(rawValue:)))
            )
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            self.subscriber.send(
                .willPresentNotification(
                    .init(rawValue: notification),
                    completionHandler: completionHandler
                )
            )
        }
    }
}

extension PushNotificationClient.Notification {
    public init(rawValue: UNNotification) {
        self.date = rawValue.date
        self.request = rawValue.request
    }
}

extension PushNotificationClient.Notification.Response {
    public init(rawValue: UNNotificationResponse) {
        self.notification = .init(rawValue: rawValue.notification)
    }
}

extension PushNotificationClient.Settings {
    public init(rawValue: UNNotificationSettings) {
        self.authorizationStatus = rawValue.authorizationStatus
    }
}

// MARK: - Live

extension PushNotificationClient {

    static func live(firestoreUserClient: FirestoreUsersClient) -> PushNotificationClient {
        PushNotificationClient(
            registerForRemoteNotifications: registerForRemoteNotificationsLive,
            delegate: delegateLive,
            setAPNSToken: { setAPNSToken(data: $0, firestoreUserClient: firestoreUserClient) }
        )
    }

    static private var delegateLive: Effect<DelegateEvent, Never> {
        Effect
            .run { subscriber in
                var delegate: Optional = Delegate(subscriber: subscriber)
                UNUserNotificationCenter.current().delegate = delegate
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

    static private func setAPNSToken(
        data: Data,
        firestoreUserClient: FirestoreUsersClient
    ) -> Effect<Bool, NSError> {
        let token = data.map { String(format: "%02.2hhx", $0) }.joined()
        print("!!!!!!!! TOKEN \(token)")
        Messaging.messaging().apnsToken = data
//        Messaging.messaging().setAPNSToken(data, type: .unknown)
//        Messaging.messaging().delegate = self
        let userUpdate = UserUpdate(fcmToken: token)
        return firestoreUserClient.updateMe(userUpdate)
    }
}
