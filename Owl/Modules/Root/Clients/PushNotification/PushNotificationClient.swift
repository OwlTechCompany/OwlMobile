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

    var getNotificationSettings: Effect<Settings, Never>
    var requestAuthorization: (UNAuthorizationOptions) -> Effect<Bool, NSError>
    var setAPNSToken: (Data) -> Void
    var register: () -> Effect<Never, Never>

    var userNotificationCenterDelegate: Effect<UserNotificationCenterDelegate.Event, Never>
    var firebaseMessagingDelegate: Effect<FirebaseMessagingDelegate.Event, Never>
}

extension PushNotificationClient {

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

    struct Settings: Equatable {
        var authorizationStatus: UNAuthorizationStatus

        init(authorizationStatus: UNAuthorizationStatus) {
            self.authorizationStatus = authorizationStatus
        }
    }

}

extension PushNotificationClient.Notification {

    init(rawValue: UNNotification) {
        self.date = rawValue.date
        self.request = rawValue.request
    }

}

extension PushNotificationClient.Notification.Response {

    init(rawValue: UNNotificationResponse) {
        self.notification = .init(rawValue: rawValue.notification)
    }

}

extension PushNotificationClient.Settings {

    init(rawValue: UNNotificationSettings) {
        self.authorizationStatus = rawValue.authorizationStatus
    }

}
