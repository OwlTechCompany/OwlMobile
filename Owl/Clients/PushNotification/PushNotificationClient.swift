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
import UserNotifications

struct PushNotificationClient {

    var getNotificationSettings: EffectPublisher<Settings, Never>
    var requestAuthorization: (UNAuthorizationOptions) -> EffectPublisher<Bool, NSError>
    var setAPNSToken: (Data) -> EffectPublisher<Void, Never>
    var register: () -> EffectPublisher<Never, Never>
    var currentFCMToken: () -> EffectPublisher<String, NSError>
    var handlePushNotification: (
        PushNotificationClient.Notification,
        _ completionHandler: @escaping (UNNotificationPresentationOptions) -> Void,
        _ openedChatId: String?
    ) -> EffectPublisher<Void, NSError>
    var handleDidReceiveResponse: (
        PushNotificationClient.Response,
        _ completionHandler: @escaping () -> Void
    ) -> EffectPublisher<PushRoute, NSError>

    var userNotificationCenterDelegate: EffectPublisher<UserNotificationCenterDelegate.Event, Never>
    var firebaseMessagingDelegate: EffectPublisher<FirebaseMessagingDelegate.Event, Never>
}

extension PushNotificationClient {

    struct Notification: Equatable {
        var date: Date
        var request: UNNotificationRequest
    }

    struct Response: Equatable {
        var notification: Notification
        var actionIdentifier: String
    }

    struct Settings: Equatable {
        var authorizationStatus: UNAuthorizationStatus
    }

}

extension PushNotificationClient.Notification {

    init(unNotification: UNNotification) {
        self.date = unNotification.date
        self.request = unNotification.request
    }

}

extension PushNotificationClient.Response {

    init(unNotificationResponse: UNNotificationResponse) {
        self.notification = PushNotificationClient.Notification(
            unNotification: unNotificationResponse.notification
        )
        self.actionIdentifier = unNotificationResponse.actionIdentifier
    }

}

extension PushNotificationClient.Settings {

    init(rawValue: UNNotificationSettings) {
        self.authorizationStatus = rawValue.authorizationStatus
    }

}

extension DependencyValues {

    var pushNotificationClient: PushNotificationClient {
        get { self[PushNotificationClientKey.self] }
        set { self[PushNotificationClientKey.self] = newValue }
    }

    enum PushNotificationClientKey: DependencyKey {
        static var testValue = PushNotificationClient.unimplemented
        static var liveValue = PushNotificationClient.live()
    }

}
