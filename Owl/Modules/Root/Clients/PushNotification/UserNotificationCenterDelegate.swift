//
//  UserNotificationCenterDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import UIKit
import ComposableArchitecture
import Combine

final class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {

    enum Event: Equatable {
        case didReceiveResponse(
            PushNotificationClient.Notification.Response,
            completionHandler: () -> Void
        )
        case openSettingsForNotification(PushNotificationClient.Notification?)
        case willPresentNotification(
            PushNotificationClient.Notification,
            completionHandler: (UNNotificationPresentationOptions) -> Void
        )

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

    let subscriber: Effect<Event, Never>.Subscriber

    init(subscriber: Effect<Event, Never>.Subscriber) {
        self.subscriber = subscriber
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        subscriber.send(
            .didReceiveResponse(.init(rawValue: response), completionHandler: completionHandler)
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        subscriber.send(
            .openSettingsForNotification(notification.map(PushNotificationClient.Notification.init(rawValue:)))
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        subscriber.send(
            .willPresentNotification(
                .init(rawValue: notification),
                completionHandler: completionHandler
            )
        )
    }
}
