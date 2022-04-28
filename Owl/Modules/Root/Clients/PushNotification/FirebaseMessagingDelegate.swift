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
            case let (.didReceiveRegistrationToken(lhs, lhsToken), .didReceiveRegistrationToken(rhs, rhsToken)):
                return lhs == rhs && lhsToken == rhsToken
            }
        }
    }

    let subscriber: Effect<FirebaseMessagingDelegate.Event, Never>.Subscriber

    init(subscriber: Effect<FirebaseMessagingDelegate.Event, Never>.Subscriber) {
        self.subscriber = subscriber
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.subscriber.send(
            .didReceiveRegistrationToken(messaging, fcmToken: fcmToken)
        )
    }

}
