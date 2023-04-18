//
//  FirebaseMessagingDelegate.swift
//  Owl
//
//  Created by Denys Danyliuk on 28.04.2022.
//

import Firebase
import ComposableArchitecture
import Combine

final class FirebaseMessagingDelegate: NSObject, MessagingDelegate {

    enum Event: Equatable {
        case didReceiveRegistrationToken(Messaging, fcmToken: String?)

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.didReceiveRegistrationToken, .didReceiveRegistrationToken):
                return false
            }
        }
    }

    let subscriber: EffectPublisher<FirebaseMessagingDelegate.Event, Never>.Subscriber

    init(subscriber: EffectPublisher<FirebaseMessagingDelegate.Event, Never>.Subscriber) {
        self.subscriber = subscriber
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        subscriber.send(
            .didReceiveRegistrationToken(messaging, fcmToken: fcmToken)
        )
    }

}
