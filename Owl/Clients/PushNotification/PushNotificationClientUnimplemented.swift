//
//  PushNotificationClientUnimplemented.swift
//  Owl
//
//  Created by Denys Danyliuk on 04.08.2022.
//

import Foundation
import XCTestDynamicOverlay
import ComposableArchitecture

extension PushNotificationClient {

    static let unimplemented = Self(
        getNotificationSettings: .unimplemented("\(Self.self).getNotificationSettings"),
        requestAuthorization: XCTUnimplemented("\(Self.self).requestAuthorization"),
        setAPNSToken: XCTUnimplemented("\(Self.self).setAPNSToken"),
        register: XCTUnimplemented("\(Self.self).register"),
        currentFCMToken: XCTUnimplemented("\(Self.self).currentFCMToken"),
        handlePushNotification: XCTUnimplemented("\(Self.self).handlePushNotification"),
        handleDidReceiveResponse: XCTUnimplemented("\(Self.self).handleDidReceiveResponse"),
        userNotificationCenterDelegate: .unimplemented("\(Self.self).userNotificationCenterDelegate"),
        firebaseMessagingDelegate: .unimplemented("\(Self.self).firebaseMessagingDelegate")
    )

}
