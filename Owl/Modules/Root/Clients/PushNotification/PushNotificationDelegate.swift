//
//  PushNotificationDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import UIKit
import ComposableArchitecture
import Combine

final class PushNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    enum Event: Equatable {
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

    let subscriber: Effect<Event, Never>.Subscriber

    init(subscriber: Effect<Event, Never>.Subscriber) {
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

extension PushNotificationDelegate.Notification {
    public init(rawValue: UNNotification) {
        self.date = rawValue.date
        self.request = rawValue.request
    }
}

extension PushNotificationDelegate.Notification.Response {
    public init(rawValue: UNNotificationResponse) {
        self.notification = .init(rawValue: rawValue.notification)
    }
}

extension PushNotificationDelegate.Settings {
    public init(rawValue: UNNotificationSettings) {
        self.authorizationStatus = rawValue.authorizationStatus
    }
}
